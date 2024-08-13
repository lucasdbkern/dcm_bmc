function GCM_creator_for_PEB_confusion_matrix()
%
    % Define the path to the main folder containing subject subfolders
    subject_folder = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/';

    % Initialize cell array to store DCMs
    GCM = cell(20, 3);

    % Loop through each subject's folder
    for subj = 1:20
        % Define the path to the derivative folder for the current subject
        derivative_folder = fullfile(subject_folder, ['subject_' num2str(subj)], 'derivatives');

        % Load the DCMij.mat file
        dcm_file = fullfile(derivative_folder, 'DCMij.mat');
        if isfile(dcm_file)
            DCM_data = load(dcm_file);

            % Check if the DCMij variable exists in the loaded file
            if isfield(DCM_data, 'DCMij')
                DCMij = DCM_data.DCMij;

                % Extract the (1,1), (2,2), and (3,3) entries and store them in the appropriate positions
                GCM{subj, 1} = DCMij{1, 1};
                GCM{subj, 2} = DCMij{1, 2};
                GCM{subj, 3} = DCMij{1, 3};
            else
                warning(['DCMij variable not found in ' dcm_file]);
            end
        else
            warning(['File not found: ' dcm_file]);
        end
    end


    % Save the populated combined_GCM cell array to GCM_combined.mat
    save(fullfile(subject_folder, 'GCM_for_PEB.mat'), 'GCM');
end
