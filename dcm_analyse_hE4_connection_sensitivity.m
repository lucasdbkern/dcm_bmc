function dcm_analyse_hE4_connection_sensitivity()
%==========================================================================
% Gradually prunes DCMs for fixed hE=4 across 20 subjects.
% Loads ORA models.
% For each subject, the connections are pruned with
% exp(0), exp(-8), and exp(-16) before inversion.
% Results are saved as a 20x3 cell array.
%==========================================================================

spm('defaults','eeg');

% Define multipliers for connection strength
multipliers = [exp(0), exp(-8), exp(-16)];

% Preallocate results: rows = subjects, cols = multipliers
DCMs = cell(20, numel(multipliers));

for subj = 1:20
    % Build paths for subject files
    subject_id = sprintf('subject_%d', subj);
    subject_folder = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/', subject_id);
    
    % Load the subject's ORA model file
    ora_filename = sprintf('subject_ORA1_%d.mat', subj);
    ora_file = fullfile(subject_folder, ora_filename);
    
    % Check if file exists
    if ~exist(ora_file, 'file')
        warning('ORA file not found for subject %d. Skipping.', subj);
        continue;
    end
    
    % Load ORA model
    loaded = load(ora_file);
    DCM_ORA = loaded.DCM;
    
    % Get TRA timeseries from DCMij
    deriv_file = fullfile(subject_folder, 'derivatives', 'DCMij.mat');
    data = load(deriv_file);
    tra_timeseries = data.DCMij{3,3}.xY.y;  % TRA timeseries

    
    for m = 1:length(multipliers)
        % Start fresh from ORA structure
        DCM_temp = DCM_ORA;
        
        % CRITICAL: Reset to unfitted state (cold start)
        DCM_temp.M.P = DCM_temp.M.pE;      % Reset parameters to prior means
        DCM_temp.Ep = DCM_temp.M.pE;        % Clear posterior estimates
        DCM_temp.Cp = [];                   % Clear posterior covariance
        DCM_temp.F = [];                    % Clear free energy
        DCM_temp.M = rmfield(DCM_temp.M, 'U'); % Remove spatial filter

        DCM_temp.M.IS = 'spm_gen_erp';  % Reset integration scheme
        DCM_temp.M.FS = 'spm_fy_erp';   % Reset observation function
        
        % Remove any fitted states
        if isfield(DCM_temp, 'K')
            DCM_temp = rmfield(DCM_temp, 'K');
        end
        if isfield(DCM_temp, 'R')
            DCM_temp = rmfield(DCM_temp, 'R');
        end
        if isfield(DCM_temp, 'H')
            DCM_temp = rmfield(DCM_temp, 'H');
        end
        if isfield(DCM_temp, 'Eg')
            DCM_temp = rmfield(DCM_temp, 'Eg');
        end
        if isfield(DCM_temp, 'Cg')
            DCM_temp = rmfield(DCM_temp, 'Cg');
        end
        
        % Attach TRA timeseries
        DCM_temp.xY.y = tra_timeseries;
        DCM_temp.options.DATA = 0;  % Don't reload data
        
        % Set inversion parameters
        DCM_temp.M.hE = 6;
        DCM_temp.M.Nmax = 128;
        
        % Apply connection strength multiplier for ORA→TRA pruning
        % For TRA model, prune bilateral A1-STG connections:
        DCM_temp.M.pC.B{1,1}(3,1) = DCM_ORA.M.pC.B{1,1}(3,1) * multipliers(m); % lA1 → lSTG
        DCM_temp.M.pC.B{1,1}(1,3) = DCM_ORA.M.pC.B{1,1}(1,3) * multipliers(m); % lSTG → lA1
        DCM_temp.M.pC.B{1,1}(4,2) = DCM_ORA.M.pC.B{1,1}(4,2) * multipliers(m); % rA1 → rSTG
        DCM_temp.M.pC.B{1,1}(2,4) = DCM_ORA.M.pC.B{1,1}(2,4) * multipliers(m); % rSTG → rA1

     
        % Name the model for tracking
        DCM_temp.name = sprintf('ORA_pruned_m%d_subj%d', m, subj);
        
        % Invert from scratch (cold start) and store the result
        fprintf('Inverting subject %d, multiplier %d...\n', subj, m);
        DCMs{subj, m} = spm_dcm_erp(DCM_temp);
    end
end

% Save results
save_path = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results', ...
                     'dcm_hE4_connection_sensitivity_ORA_reset_2.mat');
save(save_path, 'DCMs', 'multipliers');
fprintf('Results saved to %s\n', save_path);
end


% check if it does the exact same free energy to the decimal 
% call spm_vec on two dcms 
% take the one from the confusion matrix and then the exp(-16) pruned one
% for one subject and see

% plot the free energy for both dcms for both grad pruned and confusion
% matrix  - for all three architectures  --> if they are not that means
% thers a problem . 

% it might be worth to look at what is the initial value of M.pC - so on
% your line 79 

%  change DCM_ORA.M.pC.B{1,1}(3,1) to (~~DCM_ORA.M.pC.B{1,1}(3,1)) -->
%  change that 


% feval(M.IS, DCM.Ep, DCM.M, DCM.xU) --> do this for all the data for the
% gradual pruning 
% plot the odball response in one region that gets pruned -> and show how
% the strong erp decays 
% add error shaded area 
% add one panel with the confusion matrix as well 
% we can look at the erp before and after to see if there is a difference
% in non-linear components ("lobes")
% re eveluate the integrator so we can plot it
% for screenshots - computeleast square function - do norm of the residuals 