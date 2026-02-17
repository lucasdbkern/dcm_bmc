function bmr(mat_file_path)
%==========================================================================
% BMR - Bayesian Model Reduction 
%
% This function performs Bayesian Model Reduction (BMR) on a set of DCM models
% at the group level.
%==========================================================================
% Load the data
data = load(mat_file_path); 
field_name = fieldnames(data);
dcm_files = data.(field_name{1});

[num_subjects, num_models] = size(dcm_files);

% % Create a cell array to store the full models for each subject
% GCM = cell(num_subjects, 1);
% 
% % Load each subject's full model into GCM
% for i = 1:num_subjects
%     % Assumes the first model for each subject is the full model
%     GCM{i} = load(dcm_files{i, 1});
% end

% Perform Bayesian Model Reduction at the group level
[RCM, BMC, BMA] = spm_dcm_bmr(dcm_files);


% Save the results
save_path = fullfile('results');
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

save(fullfile(save_path, 'bmr_results.mat'), 'RCM', 'BMC', 'BMA');

disp('Results saved in: results/bmr_results.mat');

spm_dcm_bmc(RCM);
disp('Performed Bayesian Model Comparison')
% After running spm_dcm_bmc
[post, exp_r, xp, pxp, bor, F] = spm_dcm_bmc(RCM);
save(fullfile(save_path, 'bmr_bmc_results.mat'), 'post', 'exp_r', "xp", "pxp", 'bor', "F");


end
