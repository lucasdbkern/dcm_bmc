function group_level_bmc()
%==========================================================================
% Performs BMC for every confusion matrix using an FFX design
%==========================================================================

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

% Initialize a 3x3xN matrix to store individual free energy values
freeEnergies = zeros(3, 3, numSubjects);

% Store free energy values for each subject
for i = 1:numSubjects
    subjectFolder = fullfile(subject_folder, sortedSubfolders(i).name);
    matFilePath = fullfile(subjectFolder, 'derivatives', 'DCMij.mat');
    loadedData = load(matFilePath);
    
    for j = 1:3
        for k = 1:3
            freeEnergies(j, k, i) = loadedData(j, k).F;
        end
    end
end

% Perform BMC for each confusion matrix
for j = 1:3
    for k = 1:3
        % Extract free energy values for the current confusion matrix
        F = squeeze(freeEnergies(j, k, :));
        
        % Perform BMC using spm_dcm_bmc
        BMC = spm_dcm_bmc(F);
        
        % Print BMC results for the current confusion matrix
        fprintf('BMC Results for Confusion Matrix (%d, %d):\n', j, k);
        fprintf('Posterior Model Probabilities: %s\n', mat2str(BMC.P));
        fprintf('Exceedance Probabilities: %s\n', mat2str(BMC.xp));
        fprintf('\n');
    end
end

end