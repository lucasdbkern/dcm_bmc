function assign_timeseries_2()
    %==========================================================================
    % This function creates three structures:
    % 1. DCM_Original: Full, ORA, TRA
    % 2. DCM_ORA: Full with ORA timeseries, ORA, TRA
    % 3. DCM_TRA: Full with TRA timeseries, ORA, TRA
    %==========================================================================
    base_folder = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder';
    [DCM_Original, DCM_ORA, DCM_TRA] = process_all_subjects(base_folder);
    save(fullfile(base_folder, 'DCM_Original.mat'), 'DCM_Original');
    save(fullfile(base_folder, 'DCM_ORA.mat'), 'DCM_ORA');
    save(fullfile(base_folder, 'DCM_TRA.mat'), 'DCM_TRA');
end

function [DCM_Original, DCM_ORA, DCM_TRA] = process_all_subjects(base_folder)
    %==========================================================================
    % This function processes all subjects, creating three structures as described above.
    %
    % Inputs:
    % base_folder - Base folder containing all subject folders.
    %
    % Outputs:
    % DCM_Original, DCM_ORA, DCM_TRA - Cell arrays of DCMs for all subjects and conditions
    %==========================================================================
    
    % Initialize cell arrays to store DCMs
    DCM_Original = cell(20, 3);
    DCM_ORA = cell(20, 3);
    DCM_TRA = cell(20, 3);
    
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
        
        % Load DCMs
        full_dcm = load(fullfile(subfolder, file_names{full_idx}));
        ora_dcm = load(fullfile(subfolder, file_names{ora_idx}));
        tra_dcm = load(fullfile(subfolder, file_names{tra_idx}));
        
        % Populate DCM_Original
        DCM_Original{subject_num, 1} = full_dcm.DCM;
        DCM_Original{subject_num, 2} = ora_dcm.DCM;
        DCM_Original{subject_num, 3} = tra_dcm.DCM;
        
        % Create Full DCM with ORA timeseries
        dcm_with_ora = full_dcm.DCM;
        dcm_with_ora.xY.y = ora_dcm.DCM.xY.y;
        dcm_with_ora.M = rmfield(dcm_with_ora.M, 'U');
        dcm_with_ora.options.DATA = 0;
        
        % Populate DCM_ORA
        DCM_ORA{subject_num, 1} = dcm_with_ora;
        DCM_ORA{subject_num, 2} = ora_dcm.DCM;
        DCM_ORA{subject_num, 3} = tra_dcm.DCM;
        
        % Create Full DCM with TRA timeseries
        dcm_with_tra = full_dcm.DCM;
        dcm_with_tra.xY.y = tra_dcm.DCM.xY.y;
        dcm_with_tra.M = rmfield(dcm_with_tra.M, 'U');
        dcm_with_tra.options.DATA = 0;
        
        % Populate DCM_TRA
        DCM_TRA{subject_num, 1} = dcm_with_tra;
        DCM_TRA{subject_num, 2} = ora_dcm.DCM;
        DCM_TRA{subject_num, 3} = tra_dcm.DCM;
        
        fprintf('Processed subject %d\n', subject_num);
    end
    
    % Remove any empty rows (in case some subjects were skipped)
    DCM_Original = DCM_Original(~all(cellfun(@isempty, DCM_Original), 2), :);
    DCM_ORA = DCM_ORA(~all(cellfun(@isempty, DCM_ORA), 2), :);
    DCM_TRA = DCM_TRA(~all(cellfun(@isempty, DCM_TRA), 2), :);
    
    fprintf('Processing complete. Created DCM structures for %d subjects.\n', size(DCM_Original, 1));
end














