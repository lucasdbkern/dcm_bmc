function compare_bmc_bmr_one_subject()
%==========================================================================
% Compares Free Energy differences for a single subject.
%
% compatible with: single_subject_grad_pruning()
%==========================================================================
load_path = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results', ...
                     'grad_pruning_subject_1.mat');
data = load(load_path);  
DCMs = data.DCMs;  % 1 x n_conditions cell array

[~, n_conditions] = size(DCMs);
reduced_F = zeros(1, n_conditions);
F_diff    = zeros(1, n_conditions);

% Use the exp(0) condition as baseline.
qE = DCMs{1,1}.Ep;
qC = DCMs{1,1}.Cp;
pE = DCMs{1,1}.M.pE;
pC = DCMs{1,1}.M.pC;

for i = 1:n_conditions
    [~, rC, rE] = spm_find_pC(DCMs{1,i});
    [reduced_F(i), ~, ~] = spm_log_evidence_reduce(qE, qC, pE, pC, rE, rC);
    F_diff(i) = DCMs{1,i}.F - DCMs{1,1}.F;
end

% x-axis: exponent values for exp(-x) where x = 0,1,...,16
strengths = 0:16;

figure; hold on;
plot(strengths, reduced_F, '-', 'LineWidth', 1.5);
plot(strengths, F_diff, '--', 'LineWidth', 1.5);
xlabel('Modulatory effects connectivity (exp(-x))');
ylabel('Free Energy difference (relative to full model)');
title('Single Subject Gradual Pruning');
legend({'Reduced Free Energy', 'Variational Free Energy'}, 'Location', 'best');
grid on;
end