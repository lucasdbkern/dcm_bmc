function compare_bmc_bmr_across_subjects()
%==========================================================================
% Compares Free Energy differences between a Full DCM and modified DCMs 
% across multiple subjects.
%
% Before executing this method, run prune_connections_vary_strength()
% to generate the Variational Bayes Free Energy scores for each subject.
%
% For each subject, the Full (baseline, exp(0)) model is used to compute two
% relative differences:
%   1) Reduced Free Energy difference (BMR): computed via spm_log_evidence_reduce,
%      using the full model’s posterior and prior as the reference.
%   2) Variational Bayes Free Energy difference: simply the difference F(modified) - F(full).
%
% Baseline subtraction is applied per subject so that each subject’s exp(0)
% condition is set to zero. 
%
% Each subject’s curves are plotted individually:
%   - Solid lines: Reduced Free Energy differences (BMR)
%   - Dashed lines: Full Free Energy differences (variational Bayes) 
%
%==========================================================================
%load_path = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results', ...
                    % 'dcm_hE4_connection_sensitivity_23to33pEandpC_fixed.mat');


load_path = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results', ...
                     'dcm_hE4_connection_sensitivity_ORA_reset_2.mat');


data = load(load_path);  
DCMs = data.DCMs;

%[n_subjects x n_conditions] matrix
[n_subjects, n_conditions] = size(DCMs);
reduced_F = zeros(n_subjects, n_conditions);
F_diff    = zeros(n_subjects, n_conditions);

% For each subject, use its full (baseline) model (first condition) as reference.
for s = 1:n_subjects

    % Extract baseline parameters from the full model.
    qE = DCMs{s,1}.Ep;
    qC = DCMs{s,1}.Cp;
    pE = DCMs{s,1}.M.pE;
    pC = DCMs{s,1}.M.pC;

    for i = 1:n_conditions
        % Compute the reduced free energy difference via BMR.
        [~, rC, rE] = spm_find_pC(DCMs{s,i});
        [reduced_F(s,i), ~, ~] = spm_log_evidence_reduce(qE, qC, pE, pC, rE, rC);

        % Compute the difference in full free energy.
        F_diff(s,i) = DCMs{s,i}.F - DCMs{s,1}.F;
    end
end

% 'strengths' corresponds to the scaling factors used in the connectivity modifications.
strengths = [0;8;16];

% Plot each subject individually.
figure; hold on;
colors = lines(n_subjects);
for s = 1:n_subjects
    plot(strengths, reduced_F(s,:), '-', 'Color', colors(s,:), 'LineWidth', 1.5);
    plot(strengths, F_diff(s,:), '--', 'Color', colors(s,:), 'LineWidth', 1.5);
end

xlabel('modulatory connectivity strength covariance (exp(-x))'); % update this
ylabel('Free Energy difference (relative to full model)');
title('Gradual Free Energy Change across Subjects');
legend({'Reduced Free Energy', 'Variational Free Energy'}, 'Location', 'best');
grid on;

% Compute group mean and std for each condition
mean_reduced_F = mean(reduced_F, 1);
std_reduced_F  = std(reduced_F, 0, 1);
mean_F_diff    = mean(F_diff, 1);
std_F_diff     = std(F_diff, 0, 1);

% Plot group-level means with error bars (standard deviation std) 
figure; hold on;
errorbar(strengths, mean_reduced_F, std_reduced_F, '-o', 'LineWidth', 1.5, 'MarkerSize', 8);
errorbar(strengths, mean_F_diff, std_F_diff, '--s', 'LineWidth', 1.5, 'MarkerSize', 8);
xlabel('modulatory connectivity strength covariance (exp(-x))');
ylabel('Free Energy difference (relative to full model)');
title('Group Mean and Standard Deviation of Free Energy Differences');
legend({'BMR', 'BMC'}, 'Location', 'best');
grid on;
end



