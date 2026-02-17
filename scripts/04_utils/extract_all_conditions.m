function extract_all_conditions()
    %==========================================================================
    % This function extracts all three conditions (Full, ORA, TRA) from all subjects
    % and combines them into a single cell array.
    %==========================================================================
    base_folder = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder';
    DCM_All = process_all_subjects(base_folder);
    save(fullfile(base_folder, 'DCM_All_Conditions.mat'), 'DCM_All');
end

function DCM_All = process_all_subjects(base_folder)
    %==========================================================================
    % This function processes all subjects, extracting Full, ORA, and TRA DCMs
    % and combining them into a single cell array.
    %
    % Inputs:
    % base_folder - Base folder containing all subject folders.
    %
    % Outputs:
    % DCM_All - Cell array of DCMs for all subjects and conditions
    %           Each row represents a subject
    %           Columns: [Full, ORA, TRA]
    %==========================================================================
    
    % Initialize cell array to store DCMs
    DCM_All = cell(20, 3);
    
    % Loop through all 20 subjects
    for subject_num = 1:20
        % Define the subject folder
        subfolder = fullfile(base_folder, sprintf('subject_%d', subject_num));
        
        % Check if the subfolder exists
        if ~exist(subfolder, 'dir')
            warning('Subfolder does not exist for subject %d. Skipping.', subject_num);
            continue;
        end
        
        % List .mat files in the subfolder
        file_list = dir(fullfile(subfolder, '*.mat'));
        file_names = {file_list.name};
        
        % Find Full, ORA, and TRA files
        full_idx = find(contains(file_names, 'Full'));
        ora_idx = find(contains(file_names, 'ORA'));
        tra_idx = find(contains(file_names, 'TRA'));
        
        if isempty(full_idx) || isempty(ora_idx) || isempty(tra_idx)
            warning('Missing one or more required files (Full, ORA, or TRA) in subject %d. Skipping.', subject_num);
            continue;
        end
        
        % Load DCMs and store them in the cell array
        DCM_All{subject_num, 1} = load(fullfile(subfolder, file_names{full_idx})).DCM;
        DCM_All{subject_num, 2} = load(fullfile(subfolder, file_names{ora_idx})).DCM;
        DCM_All{subject_num, 3} = load(fullfile(subfolder, file_names{tra_idx})).DCM;
        
        fprintf('Processed subject %d\n', subject_num);
    end
    
    fprintf('Processing complete. Extracted DCM structures for %d subjects.\n', size(DCM_All, 1));
end