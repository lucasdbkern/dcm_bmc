function single_subject_grad_pruning()
%==========================================================================
% Prunes a DCM for fixed hE=4 on one subject.
% The connection pC.B{1,1}(5,4) and (4,5) is scaled by exp(0), exp(-1), ... exp(-16)
% before inversion. Results are saved as a 1x17 cell array.
%==========================================================================

spm('defaults','eeg');

% Define multipliers: from exp(0) to exp(-16) in steps of 1
multipliers = exp(0:-1:-16);

% Preallocate result cell array
DCMs = cell(1, numel(multipliers));

% Load a single subject (here, subject_1)
subject_id = 'subject_1';
file_path = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder', ...
                     subject_id, 'derivatives', 'DCMij.mat');
data = load(file_path);
DCM_base = data.DCMij{1,2};  % Assumes same indexing

for m = 1:length(multipliers)
    % Duplicate and modify DCM
    DCM_temp = DCM_base;
    DCM_temp.M.hE   = 4;
    DCM_temp.M.P    = DCM_temp.Ep;
    DCM_temp.M.Nmax = 64;
    
    % Scale connections in both directions
    %DCM_temp.M.pC.B{1,1}(5,4) = DCM_temp.M.pC.B{1,1}(5,4) * multipliers(m);
    DCM_temp.M.pC.B{1,1}(4,5) = DCM_temp.M.pC.B{1,1}(4,5) * multipliers(m);
    
    % Invert and store the result
    DCMs{m} = spm_dcm_erp(DCM_temp);
end

save_path = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results', ...
                     'grad_pruning_subject_1.mat');
save(save_path, 'DCMs', 'multipliers');
fprintf('Results saved to %s\n', save_path);
end