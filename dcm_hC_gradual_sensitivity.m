function dcm_hE_gradual_sensitivity()
%==========================================================================
% Systematically varies hE values and connection strengths to assess model sensitivity
%==========================================================================

% Initialize 
spm('defaults', 'eeg');

% Load base DCM
results = load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/subject_20/derivatives/DCMij.mat');
DCM_base = results.DCMij{1,2};

% Define parameter ranges
hE_values = 2:6;
strengths = 0:0.5:4;

% Initialize results matrix [pruning strengths x hE values]
DCMs = cell(length(strengths), length(hE_values));

% Loop through each hE value and strength
for i = 1:length(hE_values)
    for j = 1:length(strengths)
        % Create temporary DCM
        DCM_temp = DCM_base;
        
        % Set hE value
        DCM_temp.M.hE = hE_values(i);
        DCM_temp.M.P = DCM_temp.Ep;
        DCM_temp.M.Nmax = 128;
        
        % Modify connection strength
        DCM_temp.M.pC.B{1,1}(5,4) = exp(-4*strengths(j)); % What connection is that? 
        % add the backward 
        
        % Invert DCM and store result
        DCMs{j,i} = spm_dcm_erp(DCM_temp);
        
        clear DCM_temp
    end
end

% Save results
save('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/hE_gradual_sensitivity_results.mat', 'DCMs');

% Save results
save_dir = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/';
filename = 'hE_sensitivity_analysis_results.mat';
save(fullfile(save_dir, filename), 'DCMs', 'hE_values', 'strengths');

fprintf('Results saved.');
end