function compare_free_energies_validation()
%==========================================================================
% Visual comparison of free energies with differences
%==========================================================================

% Load gradual pruning results
gradual_data = load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/dcm_hE4_connection_sensitivity_ORA_reset_2.mat');
DCMs_gradual = gradual_data.DCMs;

% Initialize storage
subjects = 1:20;
F_dcmij_23 = zeros(20,1);
F_dcmij_33 = zeros(20,1);
F_gradual_exp0 = zeros(20,1);
F_gradual_exp16 = zeros(20,1);

% Collect data
for subj = 1:20
    % Get confusion matrix results
    confusion_file = sprintf('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/subject_%d/derivatives/DCMij.mat', subj);
    confusion_data = load(confusion_file);
    
    F_dcmij_23(subj) = confusion_data.DCMij{2,3}.F;
    F_dcmij_33(subj) = confusion_data.DCMij{3,3}.F;
    
    % Get gradual pruning results
    F_gradual_exp0(subj) = DCMs_gradual{subj, 1}.F;
    F_gradual_exp16(subj) = DCMs_gradual{subj, 3}.F;
end

% Calculate differences
diff_confusion = F_dcmij_23 - F_dcmij_33;
diff_gradual = F_gradual_exp0 - F_gradual_exp16;
diff_should_match = F_dcmij_23 - F_gradual_exp0;  % Should be ~0

% Print table with differences
fprintf('Subject  DCMij_2,3  DCMij_3,3  Diff_Confusion  Gradual_exp0  Gradual_exp-16  Diff_Gradual  Should_Match\n');
fprintf('-------  ---------  ---------  --------------  ------------  --------------  ------------  ------------\n');

for subj = 1:20
    fprintf('%3d      %9.2f  %9.2f  %+13.2f  %12.2f  %14.2f  %+11.2f  %+11.2f\n', ...
            subj, F_dcmij_23(subj), F_dcmij_33(subj), diff_confusion(subj), ...
            F_gradual_exp0(subj), F_gradual_exp16(subj), diff_gradual(subj), diff_should_match(subj));
end

% Create visual plots
figure('Name', 'Free Energy Comparison', 'Position', [100 100 1400 800]);

% Plot 1: Raw values as dots
plot(subjects, F_dcmij_23, 'ro', 'MarkerSize', 8, 'DisplayName', 'DCMij{2,3}');
hold on;
plot(subjects, F_dcmij_33, 'bs', 'MarkerSize', 8, 'DisplayName', 'DCMij{3,3}');
plot(subjects, F_gradual_exp0, 'g^', 'MarkerSize', 8, 'DisplayName', 'Gradual exp(0)');
plot(subjects, F_gradual_exp16, 'md', 'MarkerSize', 8, 'DisplayName', 'Gradual exp(-16)');
xlabel('Subject');
ylabel('Free Energy');
title('Raw Free Energy Values');
legend();
grid on;

% Print summary
fprintf('\n=== SUMMARY ===\n');
fprintf('Mean DCMij{2,3} - DCMij{3,3}: %+.2f\n', mean(diff_confusion));
fprintf('Mean Gradual exp(0) - exp(-16): %+.2f\n', mean(diff_gradual));
fprintf('Mean |DCMij{2,3} - Gradual exp(0)|: %.2f (should be ~0)\n', mean(abs(diff_should_match)));
fprintf('Max |DCMij{2,3} - Gradual exp(0)|: %.2f\n', max(abs(diff_should_match)));

end