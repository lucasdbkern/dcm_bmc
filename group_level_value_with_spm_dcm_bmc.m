function group_level_value_with_spm_dcm_bmc()
%==========================================================================
% Calculates the group level value for a value of choice
% Default is set to F - Free Energy Matrix
%==========================================================================
format long

% Define the path to the main folder containing subject subfolders
subject_folder = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/';

folderPattern = fullfile(subject_folder, 'subject_*');
subfolders = dir(folderPattern);
numSubjects = length(subfolders);

% Extract numbers from folder names and sort them
subjectNumbers = zeros(numSubjects, 1);
for i = 1:numSubjects
    num = regexp(subfolders(i).name, '\d+', 'match');
    subjectNumbers(i) = str2double(num{1});
end

% Sort numbers and use them to sort subfolders array
[~, sortIndex] = sort(subjectNumbers);
sortedSubfolders = subfolders(sortIndex);

% Initialize the cell array to store DCM structures
DCM = cell(numSubjects, 3, 3);
for i = 1:numSubjects
    for j = 1:3
        for k = 1:3
            subjectFolder = fullfile(subject_folder, sortedSubfolders(i).name);
            % Correctly load the .mat file
            matFilePath = fullfile(subjectFolder, 'derivatives', 'DCMij.mat');
            loadedData = load(matFilePath);
            % Store the structure in the DCM cell array
            DCM{i, j, k} = loadedData.DCMij{j, k};
        end
    end
end



% Initialize matrices to store the outputs of spm_dcm_bmc
F_reshaped = zeros(numSubjects, 3, 3);
post_reshaped = zeros(3, 3);  % Changed from (numSubjects, 3)

% Perform Bayesian model comparison for each column of the confusion matrix
for j = 1:3 % number of rows
    GCM = cell(numSubjects, 3);
    for subj = 1:numSubjects
        GCM(subj, :) = DCM(subj, :, j);
    end
    [post, ~, ~, ~, ~, F] = spm_dcm_bmc(GCM);

    % Store the outputs in the reshaped matrices
    for subj = 1:numSubjects
        for model = 1:3
            F_reshaped(subj, j, model) = F(subj, model);
        end
    end
    post_reshaped(j, :) = post;  
end

% Compute the average matrices across all subjects
groupF = sum(F_reshaped, 1); % groupF = group bayes factor 
groupF = squeeze(groupF);
groupF = groupF';
groupF = groupF - min(groupF, [], 1); 
averagePost = post_reshaped;  % No need to average, it's already aggregated
averagePost = averagePost';
% Round the probabilities for better display
averagePost = round(averagePost, 4);

% Display the average matrices as heatmaps
figure;
heatmap(groupF);
title('Average Free Energy (F) Heatmap');
xlabel('Simulated Timeseries');
ylabel('Fitted Models');
colorbar;

figure;
heatmap(averagePost);
title(' BMC Posterior Probability Heatmap');
xlabel('Simulated Timeseries');
ylabel('Fitted Models');
colorbar;


% Reporting
timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
disp(['Average Free Energy (F) Matrix as of ', timestamp, ':']);
disp(groupF);
disp(['Total subjects included: ', num2str(numSubjects)]);

save(('averageF_bmc_B_hE6.mat'), 'groupF');
save(('averagePost_bmc_B_hE6.mat'), 'averagePost');
end







