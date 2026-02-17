function kl_matrix = simple_column3_kl()
%==========================================================================
% Compute KL divergence for column 3 (TRA as data source) across hE values
% Supports folders named with either ',' or ';' as delimiter after hE=*
%==========================================================================

hE_values = [2, 3, 4, 5, 6];
models = {'Full', 'ORA', 'TRA'};
kl_matrix = zeros(3, 5); % [model, hE]

fprintf('Computing KL divergence for column 3...\n');

for hE_idx = 1:5
    hE = hE_values(hE_idx);

    % Check for both folder name formats
    dir_comma = sprintf('hE=%d, B pruned', hE);
    dir_semicolon = sprintf('hE=%d; B pruned', hE);

    if exist(dir_comma, 'dir')
        dir_name = dir_comma;
    elseif exist(dir_semicolon, 'dir')
        dir_name = dir_semicolon;
    else
        fprintf('  No folder found for hE=%d\n', hE);
        continue;
    end

    fprintf('Processing hE=%d in %s\n', hE, dir_name);
    subject_kls = nan(3, 20); % [model, subject]

    for subject = 1:20
        subject_folder = sprintf('subject_%d', subject); % use subject_%02d if folders are zero-padded
        file_path = fullfile(dir_name, subject_folder, 'derivatives', 'DCMij.mat');
        fprintf('  Trying path: %s\n', file_path);

        if ~exist(file_path, 'file')
            fprintf('  Missing file: %s\n', file_path);
            continue;
        end

        data = load(file_path);
        if ~isfield(data, 'DCMij') || isempty(data.DCMij)
            fprintf('  Empty or missing DCMij for subject %d\n', subject);
            continue;
        end

        DCMij = data.DCMij;
        data_source = 3;  % TRA

        for fitted_model = 1:3
            if fitted_model == data_source
                subject_kls(fitted_model, subject) = 0;
            else
                DCM_true = DCMij{data_source, data_source};
                DCM_fitted = DCMij{fitted_model, data_source};

                if isempty(DCM_true) || isempty(DCM_fitted)
                    fprintf('  Empty DCM entries for subject %d\n', subject);
                    continue;
                end

                try
                    kl_val = robust_kl_fixed(DCM_true, DCM_fitted);
                    subject_kls(fitted_model, subject) = kl_val;
                    fprintf('  Subject %d: KL[TRA||%s_fit] = %.4f\n', subject, models{fitted_model}, kl_val);
                catch ME
                    fprintf('  Error in KL computation for subject %d: %s\n', subject, ME.message);
                end
            end
        end
    end

    kl_matrix(:, hE_idx) = mean(subject_kls, 2, 'omitnan');
end

fprintf('\nKL Divergence Matrix (Column 3: TRA as data source)\n');
fprintf('         hE=2    hE=3    hE=4    hE=5    hE=6\n');
for model = 1:3
    fprintf('%s   ', models{model});
    for hE_idx = 1:5
        fprintf('%7.3f ', kl_matrix(model, hE_idx));
    end
    fprintf('\n');
end

fprintf('\nDone.\n');
visualise_kl_matrix(kl_matrix, {'Full', 'ORA', 'TRA'}, [2,3,4,5,6]);
end

function kl_div = robust_kl_fixed(DCM_j, DCM_i)
kl_total = 0;
n_conditions = min(length(DCM_j.H), length(DCM_i.H));

if n_conditions == 0
    kl_div = NaN;
    return;
end

for cond = 1:n_conditions
    if isempty(DCM_j.H{cond}) || isempty(DCM_i.H{cond})
        continue;
    end

    pred_j = DCM_j.H{cond};
    pred_i = DCM_i.H{cond};
    res_j = DCM_j.R{cond};
    res_i = DCM_i.R{cond};

    res_j_norm = res_j ./ (std(res_j(:)) + 1e-6);
    res_i_norm = res_i ./ (std(res_i(:)) + 1e-6);

    mu_j = mean(pred_j, 1)';
    mu_i = mean(pred_i, 1)';
    pred_scale = max(std(pred_j(:)), std(pred_i(:)));
    mu_j = mu_j / pred_scale;
    mu_i = mu_i / pred_scale;

    n_channels = size(res_j, 2);
    reg_factor = 0.01;

    Sigma_j = cov(res_j_norm) + eye(n_channels) * reg_factor;
    Sigma_i = cov(res_i_norm) + eye(n_channels) * reg_factor;

    kl_cond = simplified_kl(mu_j, Sigma_j, mu_i, Sigma_i);

    if isfinite(kl_cond) && kl_cond >= 0 && kl_cond < 20
        kl_total = kl_total + kl_cond;
    else
        fallback = 0.5 * norm(mu_j - mu_i)^2;
        kl_total = kl_total + min(fallback, 10);
    end
end

kl_div = kl_total / n_conditions;
end

function kl_div = simplified_kl(mu1, Sigma1, mu2, Sigma2)
k = length(mu1);

try
    if cond(Sigma1) > 1e8 || cond(Sigma2) > 1e8
        error('Ill-conditioned');
    end

    [V1, D1] = eig(Sigma1); d1 = max(diag(D1), 1e-6);
    [V2, D2] = eig(Sigma2); d2 = max(diag(D2), 1e-6);

    Sigma1_clean = V1 * diag(d1) * V1';
    Sigma2_clean = V2 * diag(d2) * V2';

    mu_diff = mu2 - mu1;
    Sigma2_inv_mu_diff = Sigma2_clean \ mu_diff;

    term1 = trace(Sigma2_clean \ Sigma1_clean);
    term2 = mu_diff' * Sigma2_inv_mu_diff;
    term3 = sum(log(d2)) - sum(log(d1));

    kl_div = 0.5 * (term1 + term2 - k + term3);
    kl_div = max(0, kl_div);
catch
    kl_div = 0.5 * (norm(mu1 - mu2)^2 + norm(Sigma1 - Sigma2, 'fro'));
end
end

function visualise_kl_matrix(kl_matrix, model_labels, hE_values)
%==========================================================================
% Visualize and save KL matrix as labeled heatmap
%==========================================================================

figure('Position', [200, 200, 600, 450]);
imagesc(kl_matrix);

% Create white-to-violet colormap
violet = [0.384, 0.310, 0.647];
white = [1, 1, 1];
n_colors = 256;
cmap = zeros(n_colors, 3);
for i = 1:n_colors
    w = (i-1)/(n_colors-1);
    cmap(i,:) = white * (1-w) + violet * w;
end
colormap(cmap);

colorbar;
caxis([0, max(kl_matrix(:), [], 'omitnan')]);
title('KL Divergence: TRA as Data Source', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('hE Value', 'FontSize', 12);
ylabel('Fitted Model', 'FontSize', 12);

set(gca, 'XTick', 1:length(hE_values), 'XTickLabel', ...
    arrayfun(@(x) sprintf('hE=%d', x), hE_values, 'UniformOutput', false));
set(gca, 'YTick', 1:3, 'YTickLabel', model_labels);
axis tight;
axis square;

% Text overlay
for i = 1:size(kl_matrix,1)
    for j = 1:size(kl_matrix,2)
        val = kl_matrix(i,j);
        if ~isnan(val)
            text(j, i, sprintf('%.2f', val), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 11, ...
                'FontWeight', 'bold', ...
                'Color', 'white');
        end
    end
end

% Save as JPG
saveas(gcf, 'kl_matrix_column3.jpg');
fprintf('KL matrix figure saved as kl_matrix_column3.jpg\n');
end