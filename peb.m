function peb(caseType)
%==========================================================================
% PEB - Parametric Empirical Bayes
%
% This code first loads the full models from the previously populated GCM
% It then executes PEB on the full models. Afterwards, BMR is applied in
% order to prune previously specified connections. 
%==========================================================================


% % 1st: PEB
% %==========================================================================
% Load the data
data = load('GCM_for_PEB.mat', 'GCM'); 
field_name = fieldnames(data);
dcm_files = data.(field_name{1});
switch caseType
    case 'Full'
        dcms = dcm_files(:, 1); 
    case 'ORA'
        dcms = dcm_files(:, 2); 
    case 'TRA'
        dcms = dcm_files(:, 3); 
    otherwise
        error('Invalid case type. Choose from ''Full'', ''ORA'', or ''TRA''.'); 
end

% Get the number of subjects
num_subjects = size(dcm_files, 1);



% Specify PEB model settings
% The 'all' option means the between-subject variability of each connection will
% be estimated individually
M = struct();
M.Q = 'all';

M.X = []; % gets computed automatically if you pass the empty bracket. 

% Choose field
%field = {'A','B'};
field = {'B'};
%field = {'A'};

[PEB,DCM] = spm_dcm_peb(dcms , M, field); 

%[PEB,DCM] = spm_dcm_peb(dcms , M, 'all'); 

spm_dcm_peb_review(PEB, DCM);

% Save the results
save_path = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results');
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

 %timestamp = datestr(now, 'yyyymmdd_HHMMSS');
save(fullfile(save_path, ['peb_results_' caseType '.mat']), 'PEB', 'DCM');
 
% 2nd: BMR
%==========================================================================
load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/GCM.mat');


DCM1= GCM{1,1};
DCM2= GCM{1,2};
DCM3= GCM{1,3};
%DCM1 = rmfield(DCM1, "M");
%DCM2 = rmfield(DCM2, "M");
%DCM3 = rmfield(DCM3, "M");



[BMA,BMR] = spm_dcm_peb_bmc(PEB, {DCM1, DCM2, DCM3});


% Save the BMR results
save(fullfile(save_path, ['peb_bmr_results_' caseType '.mat']), 'BMR', 'BMA');

end 









