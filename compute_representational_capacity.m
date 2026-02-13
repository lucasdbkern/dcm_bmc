function representational_kl = compute_representational_capacity()
%==========================================================================
% Computes representational capacity using your existing DCMij structure
% Complete standalone version with all necessary functions
%==========================================================================

spm('defaults', 'eeg');

n_subjects = 20;
models = {'Full', 'ORA', 'TRA'};
representational_kl = zeros(3, 3, n_subjects); % [true_model, fitted_model, subject]

fprintf('Computing representational capacity for %d subjects...\n', n_subjects);

for subject = 1:n_subjects
    fprintf('Processing subject %d/%d\n', subject, n_subjects);
    
    % Load the 3x3 DCMij matrix
    dcm_file = sprintf('subject_folder/subject_%d/derivatives/DCMij.mat', subject);
    if ~exist(dcm_file, 'file')
        warning('File not found: %s', dcm_file);
        continue;
    end
    
    data = load(dcm_file);
    
    for true_model = 1:3      % Which model's data is "true"
        for fitted_model = 1:3 % Which model architecture is fitting
            if true_model == fitted_model
                representational_kl(true_model, fitted_model, subject) = 0;
            else
                % True model generating data
                DCM_true = data.DCMij{true_model, true_model};  % Model fitted to its own data
                
                % Test model fitted to true model's data  
                DCM_fitted = data.DCMij{fitted_model, true_model}; % Key difference!
                
                % Compute KL[true || fitted_to_true_data]
                kl_val = robust_kl_fixed(DCM_true, DCM_fitted);
                representational_kl(true_model, fitted_model, subject) = kl_val;
                
                fprintf('  KL[%s||%s_fit_to_%s] = %.4f\n', ...
                    models{true_model}, models{fitted_model}, models{true_model}, kl_val);
            end
        end
    end
end

% Store and display results
rep_results.kl_matrix = representational_kl;
rep_results.mean_kl = mean(representational_kl, 3);
rep_results.std_kl = std(representational_kl, 0, 3);
rep_results.model_names = models;

display_representational_results(rep_results);
create_representational_plots(rep_results);

save('representational_capacity_results.mat', 'rep_results');
fprintf('\nResults saved to representational_capacity_results.mat\n');

% Return the results
representational_kl = rep_results;
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

function display_representational_results(rep_results)
%==========================================================================
% Display representational capacity results
%==========================================================================

fprintf('\n=== REPRESENTATIONAL CAPACITY RESULTS ===\n');
fprintf('Mean KL Divergences: KL[true_model || fitted_model]\n');
fprintf('Rows: True data source, Columns: Model trying to fit that data\n\n');

fprintf('%8s', '');
for i = 1:length(rep_results.model_names)
    fprintf('%10s', rep_results.model_names{i});
end
fprintf('\n');

for j = 1:size(rep_results.mean_kl, 1)
    fprintf('%8s', rep_results.model_names{j});
    for i = 1:size(rep_results.mean_kl, 2)
        fprintf('%10.4f', rep_results.mean_kl(j, i));
    end
    fprintf('\n');
end

% Interpretation helper
fprintf('\n=== INTERPRETATION ===\n');
fprintf('Entry (i,j) = How much info does model j lose when representing model i data\n');
fprintf('Lower values = Better representational capacity\n');
fprintf('Row 1: How well can ORA/TRA represent Full model dynamics?\n');
fprintf('Col 1: How well can Full model represent simplified dynamics?\n');
end

function create_representational_plots(rep_results)
%==========================================================================
% Create visualizations with violet colormap
%==========================================================================

figure('Position', [100, 100, 1200, 500]);

% Subplot 1: Representational capacity heatmap
subplot(1, 2, 1);
imagesc(rep_results.mean_kl);

% Use the same violet colormap
violet_color = [0.384, 0.310, 0.647];
white_color = [1, 1, 1];
n_colors = 256;
colormap_custom = zeros(n_colors, 3);
for i = 1:n_colors
    weight = (i-1)/(n_colors-1);
    colormap_custom(i, :) = white_color * (1-weight) + violet_color * weight;
end

colormap(colormap_custom);
colorbar;
title('Representational Capacity', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Model Architecture (fitted)', 'FontSize', 11);
ylabel('True Data Source', 'FontSize', 11);
set(gca, 'XTick', 1:3, 'XTickLabel', rep_results.model_names, ...
         'YTick', 1:3, 'YTickLabel', rep_results.model_names);
axis square;

% Add text annotations for better readability
for i = 1:3
    for j = 1:3
        if i ~= j
            text(j, i, sprintf('%.2f', rep_results.mean_kl(i,j)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 10, 'FontWeight', 'bold', ...
                'Color', 'white');
        end
    end
end

% Subplot 2: Cross-subject variability
subplot(1, 2, 2);
n_subjects = size(rep_results.kl_matrix, 3);
colors = lines(6);
plot_idx = 1;

for j = 1:3
    for i = 1:3
        if i ~= j
            values = squeeze(rep_results.kl_matrix(j, i, :));
            plot(1:n_subjects, values, 'o-', 'Color', colors(plot_idx,:), ...
                'LineWidth', 1.5, 'MarkerSize', 4, ...
                'DisplayName', sprintf('%s→%s', rep_results.model_names{j}, rep_results.model_names{i}));
            hold on;
            plot_idx = plot_idx + 1;
        end
    end
end

xlabel('Subject', 'FontSize', 11);
ylabel('Representational KL', 'FontSize', 11);
title('Representational Capacity Across Subjects', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
grid on;
xlim([0.5, n_subjects + 0.5]);

sgtitle('Representational Capacity Analysis', 'FontSize', 14, 'FontWeight', 'bold');
end

function quick_test_representational()
%==========================================================================
% Quick test with one subject to verify everything works
%==========================================================================

fprintf('Testing representational capacity analysis with subject 1...\n');

% Load the 3x3 DCMij matrix for subject 1
dcm_file = 'subject_folder/subject_1/derivatives/DCMij.mat';
if ~exist(dcm_file, 'file')
    fprintf('ERROR: File not found: %s\n', dcm_file);
    return;
end

data = load(dcm_file);
models = {'Full', 'ORA', 'TRA'};

fprintf('\nTesting representational capacity calculations:\n');

for true_model = 1:3
    for fitted_model = 1:3
        if true_model ~= fitted_model
            DCM_true = data.DCMij{true_model, true_model};
            DCM_fitted = data.DCMij{fitted_model, true_model};
            
            kl_val = robust_kl_fixed(DCM_true, DCM_fitted);
            fprintf('KL[%s||%s_fit_to_%s] = %.4f\n', ...
                models{true_model}, models{fitted_model}, models{true_model}, kl_val);
        end
    end
end

fprintf('\nTest completed successfully!\n');
end