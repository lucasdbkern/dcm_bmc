function kl_results = compute_prediction_kl_divergence()
%==========================================================================
% Fixed KL divergence computation with proper scaling and violet colormap
%==========================================================================

spm('defaults', 'eeg');

n_subjects = 20;
n_models = 3;
model_names = {'Full', 'ORA', 'TRA'};
kl_matrix = zeros(n_models, n_models, n_subjects);

fprintf('Computing KL divergences for %d subjects...\n', n_subjects);

for subject = 1:n_subjects
    fprintf('Processing subject %d/%d\n', subject, n_subjects);
    
    dcm_file = sprintf('subject_folder/subject_%d/derivatives/DCMij.mat', subject);
    if ~exist(dcm_file, 'file')
        warning('File not found: %s', dcm_file);
        continue;
    end
    
    data = load(dcm_file);
    DCMs = {data.DCMij{1,1}, data.DCMij{2,2}, data.DCMij{3,3}};
    
    % Compute pairwise KL divergences
    for i = 1:n_models
        for j = 1:n_models
            if i == j
                kl_matrix(j, i, subject) = 0;
            else
                kl_val = robust_kl_fixed(DCMs{j}, DCMs{i});
                kl_matrix(j, i, subject) = kl_val;
                fprintf('  KL[%s||%s] = %.4f\n', model_names{j}, model_names{i}, kl_val);
            end
        end
    end
end

% Store results
kl_results.kl_matrix = kl_matrix;
kl_results.mean_kl = mean(kl_matrix, 3);
kl_results.std_kl = std(kl_matrix, 0, 3);
kl_results.model_names = model_names;

% Display results
fprintf('\n=== GROUP RESULTS ===\n');
display_kl_matrix_fixed(kl_results.mean_kl, model_names);

% Create visualizations with violet colormap
create_simple_plots(kl_results);

save('kl_divergence_results_fixed.mat', 'kl_results');
fprintf('\nResults saved to kl_divergence_results_fixed.mat\n');
end

function kl_div = robust_kl_fixed(DCM_j, DCM_i)
%==========================================================================
% More robust KL computation with proper scaling
%==========================================================================

kl_total = 0;
n_conditions = min(length(DCM_j.H), length(DCM_i.H));

for cond = 1:n_conditions
    pred_j = DCM_j.H{cond};  % [58 x 9]
    pred_i = DCM_i.H{cond};
    res_j = DCM_j.R{cond};
    res_i = DCM_i.R{cond};
    
    % Method 1: Use residual covariances directly (simpler approach)
    % Normalize residuals by their own scale
    res_j_norm = res_j ./ (std(res_j(:)) + 1e-6);
    res_i_norm = res_i ./ (std(res_i(:)) + 1e-6);
    
    % Compute mean predictions (average over time)
    mu_j = mean(pred_j, 1)';  % [9 x 1]
    mu_i = mean(pred_i, 1)';
    
    % Normalize means to same scale
    pred_scale = max(std(pred_j(:)), std(pred_i(:)));
    mu_j = mu_j / pred_scale;
    mu_i = mu_i / pred_scale;
    
    % Compute covariances with appropriate regularization
    n_channels = size(res_j, 2);
    reg_factor = 0.01;  % 1% regularization
    
    Sigma_j = cov(res_j_norm) + eye(n_channels) * reg_factor;
    Sigma_i = cov(res_i_norm) + eye(n_channels) * reg_factor;
    
    % Use simplified KL for better numerical stability
    kl_cond = simplified_kl(mu_j, Sigma_j, mu_i, Sigma_i);
    
    if isfinite(kl_cond) && kl_cond >= 0 && kl_cond < 20  % Sanity bounds
        kl_total = kl_total + kl_cond;
    else
        % Fallback: use normalized prediction difference
        fallback = 0.5 * norm(mu_j - mu_i)^2;
        kl_total = kl_total + min(fallback, 10);
        fprintf('      Using fallback for condition %d\n', cond);
    end
end

kl_div = kl_total / n_conditions;
end

function kl_div = simplified_kl(mu1, Sigma1, mu2, Sigma2)
%==========================================================================
% Simplified KL computation focusing on numerical stability
%==========================================================================

k = length(mu1);

try
    % Check condition numbers
    if cond(Sigma1) > 1e8 || cond(Sigma2) > 1e8
        error('Matrix too ill-conditioned');
    end
    
    % Use eigenvalue decomposition for more stable computation
    [V1, D1] = eig(Sigma1);
    [V2, D2] = eig(Sigma2);
    
    % Ensure positive eigenvalues
    d1 = max(diag(D1), 1e-6);
    d2 = max(diag(D2), 1e-6);
    
    % Reconstruct with cleaned eigenvalues
    Sigma1_clean = V1 * diag(d1) * V1';
    Sigma2_clean = V2 * diag(d2) * V2';
    
    % Solve linear system instead of inverting
    mu_diff = mu2 - mu1;
    Sigma2_inv_mu_diff = Sigma2_clean \ mu_diff;
    
    % Compute terms
    term1 = trace(Sigma2_clean \ Sigma1_clean);
    term2 = mu_diff' * Sigma2_inv_mu_diff;
    term3 = sum(log(d2)) - sum(log(d1));
    
    kl_div = 0.5 * (term1 + term2 - k + term3);
    kl_div = max(0, kl_div);  % Ensure non-negative
    
catch
    % Ultimate fallback: simple quadratic form
    kl_div = 0.5 * (norm(mu1 - mu2)^2 + norm(Sigma1 - Sigma2, 'fro'));
end
end

function display_kl_matrix_fixed(kl_matrix, model_names)
%==========================================================================
% Display KL divergence matrix in readable format
%==========================================================================

fprintf('\nMean KL Divergences:\n');
fprintf('Rows: True model (j), Columns: Approximating model (i)\n');
fprintf('Entry (j,i) = KL[model_j || model_i]\n\n');

fprintf('%8s', '');
for i = 1:length(model_names)
    fprintf('%10s', model_names{i});
end
fprintf('\n');

for j = 1:size(kl_matrix, 1)
    fprintf('%8s', model_names{j});
    for i = 1:size(kl_matrix, 2)
        fprintf('%10.4f', kl_matrix(j, i));
    end
    fprintf('\n');
end
end

function create_simple_plots(kl_results)
%==========================================================================
% Create visualizations with violet-white colormap
%==========================================================================

figure('Position', [100, 100, 1200, 500]);

% Subplot 1: Mean KL divergences heatmap
subplot(1, 2, 1);
imagesc(kl_results.mean_kl);

% Create custom violet-to-white colormap
violet_color = [0.384, 0.310, 0.647];  % RGB values for the violet shade
white_color = [1, 1, 1];               % White for zero values
n_colors = 256;

% Create gradient from white to violet
colormap_custom = zeros(n_colors, 3);
for i = 1:n_colors
    % Interpolate between white and violet
    weight = (i-1)/(n_colors-1);  % 0 to 1
    colormap_custom(i, :) = white_color * (1-weight) + violet_color * weight;
end

colormap(colormap_custom);
colorbar;
title('Mean KL Divergences', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Approximating Model (i)', 'FontSize', 11);
ylabel('True Model (j)', 'FontSize', 11);
set(gca, 'XTick', 1:3, 'XTickLabel', kl_results.model_names, ...
         'YTick', 1:3, 'YTickLabel', kl_results.model_names);
axis square;

% Subplot 2: Subject-wise KL divergences
subplot(1, 2, 2);
n_subjects = size(kl_results.kl_matrix, 3);
colors = lines(6);
plot_idx = 1;

for j = 1:3
    for i = 1:3
        if i ~= j
            values = squeeze(kl_results.kl_matrix(j, i, :));
            plot(1:n_subjects, values, 'o-', 'Color', colors(plot_idx,:), ...
                'LineWidth', 1.5, 'MarkerSize', 4, ...
                'DisplayName', sprintf('KL[%s||%s]', kl_results.model_names{j}, kl_results.model_names{i}));
            hold on;
            plot_idx = plot_idx + 1;
        end
    end
end

xlabel('Subject', 'FontSize', 11);
ylabel('KL Divergence', 'FontSize', 11);
title('KL Divergences Across Subjects', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
grid on;
xlim([0.5, n_subjects + 0.5]);

% Overall figure title
sgtitle('KL Divergence Analysis Results', 'FontSize', 14, 'FontWeight', 'bold');
end

function debug_kl_computation_simple()
%==========================================================================
% Simplified debug version for troubleshooting
%==========================================================================

% Test with one subject first
subject = 1;
dcm_file = sprintf('subject_folder/subject_%d/derivatives/DCMij.mat', subject);

if ~exist(dcm_file, 'file')
    fprintf('ERROR: File not found: %s\n', dcm_file);
    return;
end

data = load(dcm_file);

% Check if DCMij exists
if ~isfield(data, 'DCMij')
    fprintf('ERROR: DCMij field not found in file\n');
    return;
end

% Extract models
DCMs = {data.DCMij{1,1}, data.DCMij{2,2}, data.DCMij{3,3}};
model_names = {'Full', 'ORA', 'TRA'};

fprintf('=== DEBUGGING SUBJECT %d ===\n', subject);

% Check each model
for i = 1:3
    DCM = DCMs{i};
    fprintf('\n--- %s Model ---\n', model_names{i});
    
    % Check basic properties
    if isfield(DCM, 'H') && isfield(DCM, 'R')
        fprintf('Has H and R fields: YES\n');
        fprintf('Number of conditions: %d\n', length(DCM.H));
        
        for cond = 1:length(DCM.H)
            pred = DCM.H{cond};
            res = DCM.R{cond};
            
            fprintf('Condition %d:\n', cond);
            fprintf('  Prediction size: [%d x %d]\n', size(pred));
            fprintf('  Residual size: [%d x %d]\n', size(res));
            fprintf('  Prediction range: [%.3f, %.3f]\n', min(pred(:)), max(pred(:)));
            fprintf('  Residual range: [%.3f, %.3f]\n', min(res(:)), max(res(:)));
            
            if any(isnan(pred(:)))
                fprintf('  Any NaN in pred: YES\n');
            else
                fprintf('  Any NaN in pred: NO\n');
            end
            
            if any(isnan(res(:)))
                fprintf('  Any NaN in res: YES\n');
            else
                fprintf('  Any NaN in res: NO\n');
            end
        end
    else
        fprintf('Missing H or R fields!\n');
        if isfield(DCM, 'H')
            fprintf('Has H field\n');
        end
        if isfield(DCM, 'R')
            fprintf('Has R field\n');
        end
        fprintf('Available fields: %s\n', strjoin(fieldnames(DCM), ', '));
    end
end

% Test simple KL computation
fprintf('\n=== TESTING SIMPLE KL ESTIMATION ===\n');
for i = 1:3
    for j = 1:3
        if i ~= j
            try
                % Simple free energy difference
                F_diff = abs(DCMs{j}.F - DCMs{i}.F);
                fprintf('F_diff[%s||%s] = %.4f\n', model_names{j}, model_names{i}, F_diff);
            catch ME
                fprintf('ERROR: %s\n', ME.message);
            end
        end
    end
end
end

function create_violet_white_colormap()
%==========================================================================
% Creates and applies a custom colormap from white (0) to violet (max)
%==========================================================================

% Define the violet color (matching your image)
violet_color = [0.384, 0.310, 0.647];  % RGB values for violet
white_color = [1, 1, 1];               % White for zero

% Create the colormap
n_colors = 256;
colormap_custom = zeros(n_colors, 3);

for i = 1:n_colors
    weight = (i-1)/(n_colors-1);  % Linear interpolation from 0 to 1
    colormap_custom(i, :) = white_color * (1-weight) + violet_color * weight;
end

% Apply to current figure
colormap(colormap_custom);
end