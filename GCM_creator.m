function GCM_creator()
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

                % Extract the (1,1) entry and store it in the appropriate position
                GCM{subj, 1} = DCMij{1, 1};
                GCM{subj, 2} = DCMij{2, 2};
                GCM{subj, 3} = DCMij{3, 3};
            else
                warning(['DCMij variable not found in ' dcm_file]);
            end
        else
            warning(['File not found: ' dcm_file]);
        end
    end

    % Save the populated DCM_All cell array to GCM.mat
    save(fullfile(subject_folder, 'GCM.mat'), 'GCM');
end



