function peb2

% Load the data
 data = load('DCM_All_Conditions.mat', 'DCM_All'); 
 field_name = fieldnames(data);
 dcm_files = data.(field_name{1});
 full_dcms = dcm_files(:, 1);

% Get the number of subjects
num_subjects = size(dcm_files, 1);



% Specify PEB model settings
% The 'all' option means the between-subject variability of each connection will
% be estimated individually
M = struct();
M.Q = 'all';

M.X = []; % gets computed automatically if you pass the empty bracket. 

% Choose field
field = {'A'};

[PEB,DCM] = spm_dcm_peb(full_dcms, M, field); 


% Save the results
save_path = fullfile('results');
if ~exist(save_path, 'dir')
    mkdir(save_path);
end
% 
% timestamp = datestr(now, 'yyyymmdd_HHMMSS');
% save(fullfile(save_path, ['peb_results_' timestamp '.mat']), 'PEB', 'DCM');


% 2nd: BMR
%==========================================================================
% Replace the first column of dcm_files with the DCM results from PEB
reduced_dcms = cell(num_subjects, 3); % second input is the number of conditions

for i = 1:num_subjects
    reduced_dcms{i, 1} = DCM{i};  % Updated full model
    reduced_dcms{i, 2} = dcm_files{i, 2}; 
    reduced_dcms{i, 3} = dcm_files{i, 3};
end



% % uncomment and run this code when trying to build the confusion matrix for the
% % reduced models, 
% 
% % Load the data
% 
% pruned_data = load(mat_file_path); 
% pruned_field_name = fieldnames(pruned_data);
% pruned_dcm_files = pruned_data.(pruned_field_name{1});
% 

% 
% % Populate the reduced_dcms array
% for i = 1:num_subjects
%     reduced_dcms{i, 1} = DCM{i};  % Updated full model after PEB
%     reduced_dcms{i, 2} = load(pruned_dcm_files{i, 2}); % Load second column data
%     reduced_dcms{i, 3} = load(pruned_dcm_files{i, 3}); % Load third column data
% end



% Perform Bayesian Model Reduction (BMR)
[RCM, BMC, BMA] = spm_dcm_bmr(reduced_dcms);

disp(BMC.F);
% sum up over the columns (subjects) for the different modelsand divide by the total
% / --> obtain BMC:F this way
% or just call spm_dcm_bmc(RCM)? --> probably both equivalent


% Save the BMR results
save(fullfile(save_path, ['bmr_results_' timestamp '.mat']), 'RCM', 'BMC', 'BMA');

end 


