function assign_timeseries()
    %==========================================================================
    % This function creates three structures:
    % 1. DCM_Original: Full, ORA, TRA
    % 2. DCM_ORA: Full with ORA timeseries, ORA, TRA
    % 3. DCM_TRA: Full with TRA timeseries, ORA, TRA
    %==========================================================================
    base_folder = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder';
    gcm_file = fullfile(base_folder, 'GCM.mat');
    
    if isfile(gcm_file)
        load(gcm_file, 'GCM');
        [DCM_Original, DCM_ORA, DCM_TRA] = process_all_subjects(GCM);
        save(fullfile(base_folder, 'DCM_Original.mat'), 'DCM_Original');
        save(fullfile(base_folder, 'DCM_ORA.mat'), 'DCM_ORA');
        save(fullfile(base_folder, 'DCM_TRA.mat'), 'DCM_TRA');
    else
        error('GCM.mat file not found.');
    end
end

function [DCM_Original, DCM_ORA, DCM_TRA] = process_all_subjects(GCM)
    %==========================================================================
    % This function processes all subjects, creating three structures as described above.
    %
    % Inputs:
    % GCM - Cell array of DCM structures for all subjects and conditions.
    %
    % Outputs:
    % DCM_Original, DCM_ORA, DCM_TRA - Cell arrays of DCMs for all subjects and conditions
    %==========================================================================
    
    % Initialize cell arrays to store DCMs
    DCM_Original = cell(size(GCM, 1), 3);
    DCM_ORA = cell(size(GCM, 1), 3);
    DCM_TRA = cell(size(GCM, 1), 3);
    
    % Loop through all subjects
    for subject_num = 1:size(GCM, 1)
        
        % Load DCMs from the GCM structure
        full_dcm = GCM{subject_num, 1};
        ora_dcm = GCM{subject_num, 2};
        tra_dcm = GCM{subject_num, 3};
        
        % Populate DCM_Original
        DCM_Original{subject_num, 1} = full_dcm;
        DCM_Original{subject_num, 2} = ora_dcm;
        DCM_Original{subject_num, 3} = tra_dcm;
        
        % Create Full DCM with ORA timeseries
        dcm_with_ora = full_dcm;
        dcm_with_ora.xY.y = ora_dcm.xY.y;
        dcm_with_ora.M = rmfield(dcm_with_ora.M, 'U');
        dcm_with_ora.options.DATA = 0;
        
        % Populate DCM_ORA
        DCM_ORA{subject_num, 1} = dcm_with_ora;
        DCM_ORA{subject_num, 2} = ora_dcm;
        DCM_ORA{subject_num, 3} = tra_dcm;
        
        % Create Full DCM with TRA timeseries
        dcm_with_tra = full_dcm;
        dcm_with_tra.xY.y = tra_dcm.xY.y;
        dcm_with_tra.M = rmfield(dcm_with_tra.M, 'U');
        dcm_with_tra.options.DATA = 0;
        
        % Populate DCM_TRA
        DCM_TRA{subject_num, 1} = dcm_with_tra;
        DCM_TRA{subject_num, 2} = ora_dcm;
        DCM_TRA{subject_num, 3} = tra_dcm;
        
        fprintf('Processed subject %d\n', subject_num);
    end
    
    % Remove any empty rows (in case some subjects were skipped)
    DCM_Original = DCM_Original(~all(cellfun(@isempty, DCM_Original), 2), :);
    DCM_ORA = DCM_ORA(~all(cellfun(@isempty, DCM_ORA), 2), :);
    DCM_TRA = DCM_TRA(~all(cellfun(@isempty, DCM_TRA), 2), :);
    
    fprintf('Processing complete. Created DCM structures for %d subjects.\n', size(DCM_Original, 1));
end









