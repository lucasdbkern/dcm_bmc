function run_bmc_per_subject(subject_folder)
%==========================================================================
%This function performs Bayesian Model Comparison on the generated subjects.

% Ensure to wrap file paths in brackets {file, file2, file3} for proper functionality.

% Inputs:
%   subject_folder      - Folder containing the generated subjects.
 
%==========================================================================

spm('defaults', 'eeg')

% Define the subfolder path
subfolder = fullfile(subject_folder, sprintf('subject_%s');

% Check if the subfolder exists
if ~exist(subfolder, 'dir')
    error('The specified subfolder does not exist: %s', subfolder);
end

% List .mat files in the subfolder
file_list = dir(fullfile(subfolder, '*.mat'));
file_paths = fullfile({file_list.folder}, {file_list.name});


DCMs = {};
for i = 1:n 
    loaded_data = load(file_paths{i});
    DCMs{i} = loaded_data.DCM;
    DCMs{i}.M.Nmax = 64;
end


DCMij = cell(n, n);
for i = 1:n
    for j = 1:n
        DCMtemp = DCMs{i};
        DCMtemp.options.DATA = 0; 
        DCMtemp.xY.y = DCMs{j}.xY.y;
        DMCtemp.M = rmfield(DCMtemp.M, 'U'); 
        DCMtemp.name = spm_file(DCMtemp.name, 'prefix', 'bmc_');
        DCMij{i,j} = spm_dcm_erp(DCMtemp);
        clear DCMtemp; 
    end
end



% Create the subfolder path
subfolder = fullfile(subject_folder_new, sprintf('subject_%s', param_key), 'derivatives');

% Check if the subfolder exists, and create it if it doesn't
if ~exist(subfolder, 'dir')
    mkdir(subfolder);
end

% Define the full file path for saving DCMij.mat
filename = fullfile(subfolder, 'DCMij.mat');

% Save the DCMij cell array to the specified file
save(filename, 'DCMij');

fprintf('DCMij saved to %s\n', filename);
end






