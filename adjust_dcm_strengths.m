function adjust_dcm_strengths(n)
%==========================================================================
%This function loads DCMs and then then modifies the connection strengths in the model 
% by applying a range of scaling factors (defined in 'strengths'). 
% Each modified DCM is inverted using the function `spm_dcm_erp`, 
% and the resulting DCMs are saved in a specified output file.

%==========================================================================


spm('defaults', 'eeg');

% Define the strengths array
strengths = 0:0.1:4;
n_subjects = 20;

switch n
    case 1
        % Initialize: [subjects x strengths]
        DCMs_multi = cell(n_subjects, length(strengths));
        
        for subj = 1:n_subjects            
            % Load subject-specific DCM
            results = load(sprintf('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/subject_%d/derivatives/DCMij.mat', subj));
            DCM_adj = results.DCMij{1,2};
            
            % Loop through strengths for this subject
            for i = 1:length(strengths)
                DCM_temp = DCM_adj;
                DCM_temp.M.P = DCM_temp.Ep;
                DCM_temp.M.Nmax = 64;
                DCM_temp.M.hE = 6;
                DCM_temp.M = rmfield(DCM_temp.M, 'U'); % Remove spatial filter
                DCM_temp.M.P = DCM_temp.M.pE;      % Reset parameters to prior means
                DCM_temp.Ep = DCM_temp.M.pE;        % Clear posterior estimates
                DCM_temp.Cp = [];                   % Clear posterior covariance
                DCM_temp.F = [];                    % Clear free energy

                %DCM_temp.M.IS = 'spm_gen_erp';  % Reset integration scheme
                %DCM_temp.M.FS = 'spm_fy_erp';   % Reset observation function            
                
                % Apply pruning
                DCM_temp.M.pC.B{1,1}(5,4) = exp(-4*strengths(i));
                DCM_temp.M.pC.B{1,1}(4,5) = exp(-4*strengths(i));

                %DCM_temp.M.pC.B{1,1}(3,1) = exp(-4*strengths(i));
                %DCM_temp.M.pC.B{1,1}(1,3) = exp(-4*strengths(i));
                %DCM_temp.M.pC.B{1,1}(4,2) = exp(-4*strengths(i));
                %DCM_temp.M.pC.B{1,1}(2,4) = exp(-4*strengths(i));


                
                % Invert and store
                DCMs_multi{subj, i} = spm_dcm_erp(DCM_temp);
                clear DCM_temp;
            end
        end
        
        % Save multi-subject results
        filepath = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/', 'DCMs_multi_subject_final_fine_pruning_bmr_fail.mat');
        save(filepath, 'DCMs_multi', 'strengths');
        
    case 2
        % Initialize: [subjects x strengths x strengths]
        DCMs_multi_2param = cell(n_subjects, length(strengths), length(strengths));
        
        for subj = 1:n_subjects            
            results = load(sprintf('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/subject_%d/derivatives/DCMij.mat', subj));
            DCM_adj = results.DCMij{1,2};
            
            for i = 1:length(strengths)
                for j = 1:length(strengths)
                    DCM_temp = DCM_adj;
                    DCM_temp.M.P = DCM_temp.Ep;
                    DCM_temp.M.Nmax = 256;
                    
                    % Apply 2-parameter pruning
                    DCM_temp.M.pC.B{1,1}(5,4) = exp(-4*strengths(i));
                    DCM_temp.M.pC.B{1,1}(4,5) = exp(-4*strengths(j));

                    
                    
                    DCMs_multi_2param{subj, i, j} = spm_dcm_erp(DCM_temp);
                    clear DCM_temp;
                end
            end
        end
        
        % Save multi-subject 2-parameter results
        filepath = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/', 'DCMs_multi_subject_2param.mat');
        save(filepath, 'DCMs_multi_2param', 'strengths');
end

fprintf('Multi-subject DCMs saved.\n');
end


















