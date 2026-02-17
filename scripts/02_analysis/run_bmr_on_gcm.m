function bayesianmodelreduction(mat_file_path)
%==========================================================================
% BMR - Bayesian Model Reduction and Averaging
%
% This function performs Bayesian Model Reduction (BMR) on a set of DCM models
% and calculates the average BMC.F (Free Energy) across all subjects.
%==========================================================================

    data = load(mat_file_path); 
    field_name = fieldnames(data);
    dcm_files = data.(field_name{1});

    
    [num_rows, num_cols] = size(dcm_files);

    disp(num_rows);
    disp(num_cols);
    
    for i = 1:num_rows
        current_row = dcm_files(i, :);
        [RCM, BMC, BMA] = spm_dcm_bmr(current_row);
        
        % save the results
        save_path = fullfile('subject_folder', sprintf('subject_%d', i), 'reduced');
        if ~exist(save_path, 'dir')
            mkdir(save_path);
        end
        save(fullfile(save_path, 'bmr_results.mat'), 'RCM', 'BMC', 'BMA');

        average_BMC_F
    end
end

function average_BMC_F()
    % Define the path to the main folder containing subject subfolders
    subject_folder = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/';
    
    % Get all subject folders
    folderPattern = fullfile(subject_folder, 'subject_*');
    subfolders = dir(folderPattern);
    numSubjects = length(subfolders);
    
    all_BMC_F = [];
    

    for i = 1:numSubjects
        subjectFolder = fullfile(subject_folder, subfolders(i).name);
        

        bmr_results_path = fullfile(subjectFolder, 'reduced', 'bmr_results.mat');
        
        if exist(bmr_results_path, 'file')

            load(bmr_results_path, 'BMC');
            

            if isfield(BMC, 'F')
                all_BMC_F = cat(2, all_BMC_F, BMC.F);
            else
                warning('BMC.F not found in subject %d', i);
            end
        else
            warning('bmr_results.mat not found for subject %d', i);
        end
    end
    

    average_BMC_F = mean(all_BMC_F, 2);

    disp('Average BMC.F across all subjects:');
    disp(average_BMC_F);
    

    figure;
    bar(average_BMC_F);
    title('Average BMC.F across all subjects');
    xlabel('Model');
    ylabel('Average Free Energy');
    

    save(fullfile(subject_folder, 'average_BMC_F.mat'), 'average_BMC_F');   
    disp(['Results saved to ' fullfile(subject_folder, 'average_BMC_F.mat')]);
end

