function dcm_hE_sensitivity_analysis
%==========================================================================
% The function:
% 1. Loads an empirical DCM
% 2. Creates pruned versions with different hE settings
% 3. Generates timeseries from pruned models
% 4. Fits full model to pruned timeseries
% 5. Saves results 
%==========================================================================

spm('defaults', 'eeg');

% Set parameters
hE_values = 2:6; 
n_models = length(hE_values);

% Initialize results structure
DCM_result = cell(n_models, 1); % Store confusion matrix for each hE

% Load base DCM
results = load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/DCM_30-May-2024_2.mat');
DCM_base = results.DCM;

% Loop through each hE value
for hE_idx = 1:length(hE_values)
    hE = hE_values(hE_idx);
    
    % Create pruned DCM with current hE
    DCM_pruned = DCM_base;
    DCM_pruned.M.hE = hE; % Set hyperparameter
    
    % Prune backward connection by setting precise prior
    DCM_pruned.M.pC.B{1,1}(5,4) = exp(-16); % Very precise prior around zero
    
    % Generate timeseries from pruned model
    DCM_pruned.options.DATA = 0;
    DCM_pruned = spm_dcm_erp(DCM_pruned);
        
    % Fit full model to pruned timeseries
    DCM_temp = DCM_base;
    DCM_temp.M.hE = hE;
    DCM_temp.options.DATA = 0;
    DCM_temp.xY.y = DCM_pruned.xY.y;
    % Fit full model with pruned timeseries
    DCM_fitted = spm_dcm_erp(DCM_temp);
    
    % Store results
    DCM_result{hE_idx} = DCM_fitted;
    clear DCM_temp

end

% Save results
save_dir = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/';
filename = 'hE_sensitivity_analysis_results.mat';
save(fullfile(save_dir, filename), 'DCM_result');



