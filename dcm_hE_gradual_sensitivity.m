function dcm_hE_gradual_sensitivity()
%==========================================================================
% Systematically varies hE values and connection strengths to assess model sensitivity
%==========================================================================

% Initialise 
spm('defaults', 'eeg');

% Load base DCM
results = load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/subject_19/derivatives/DCMij.mat');
DCM_base = results.DCMij{1,2};

% Define parameter ranges
hE_values = 2:6;
strengths = 0:0.5:4;

% Initialise results matrix [pruning strengths x hE values]
DCMs = cell(length(strengths), length(hE_values));

% Loop through each hE value and strength
for i = 1:length(hE_values)
    for j = 1:length(strengths)
        % Create temporary DCM
        DCM_temp = DCM_base;
        
        % Set hE value
        DCM_temp.M.hE = hE_values(i);
        DCM_temp.M.P = DCM_temp.Ep;
        %DCM_temp.M.Nmax = 128;
        DCM_temp.M.Nmax = 64;
        
        % Modify connection strength
        %DCM_temp.M.pC.B{1,1}(5,4) = exp(-4*strengths(j));

        %DCM_temp.M.pE.A{1,1}(5,4) =0;
        %DCM_temp.M.pE.B{1,1}(4,5) =0;


        DCM_temp.M.pC.B{1,1}(5,4) =DCM_temp.M.pC.B{1,1}(5,4) * exp(-4*strengths(j));
        %DCM_temp.M.pC.B{1,1}(4,5) =DCM_temp.M.pC.B{1,1}(4,5) * exp(-4*strengths(j));
        

        %DCM_temp.Ep = DCM_temp.M.pE;  % Reset posterior mean to the new prior
        %DCM_temp.Cp = DCM_temp.M.pC;  % Reset posterior covariance to the new prior covariance

        
        % add the backward connection too 
        
        % Invert DCM and store result
        DCMs{j,i} = spm_dcm_erp(DCM_temp);
        
        clear DCM_temp
    end
end

% Save results
save('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/hE_gradual_sensitivity_results_7.mat', 'DCMs');
% 
% % Save results
% save_dir = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/';
% filename = 'hE_sensitivity_analysis_results4_5.mat';
% save(fullfile(save_dir, filename), 'DCMs', 'hE_values', 'strengths');

fprintf('Results saved.');
end