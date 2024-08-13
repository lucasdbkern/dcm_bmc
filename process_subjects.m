function process_subjects()

% Define the path to the main folder containing subject subfolders
subject_folder = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder';

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

disp(sortedSubfolders);

GCM = cell(numSubjects, 3);
filePaths = cell(numSubjects, 3);

% Loop through each sorted subject folder
for i = 1:numSubjects
    subjectFolder = fullfile(subject_folder, sortedSubfolders(i).name);
    subjectNum = regexp(sortedSubfolders(i).name, '\d+', 'match');
    subjectNum = subjectNum{1}; 

    modelNames = {'FullA1', 'ORA1', 'TRA1'};

        for j = 1:3
            filename = sprintf('subject_%s_%s.mat', modelNames{j}, subjectNum);
            filepath = fullfile(subjectFolder, filename);

            % Load the file
            data = load(filepath);

            % Check if 'DCMi' exists and rename it to 'DCM'
            if isfield(data, 'DCMi')
                data.DCM = data.DCMi;
                data = rmfield(data, 'DCMi');

                % Save the modified structure back to the file
                save(filepath, '-struct', 'data');
            end

            % Store the modified data in GCM
            GCM{i, j} = data;

            % Store the file paths in filePaths
            filePaths{i, j} = filename;
        end

    GCM{i, 1} = load(fullfile(subjectFolder, sprintf('subject_FullA1_%s.mat', subjectNum)));
    GCM{i, 2} = load(fullfile(subjectFolder, sprintf('subject_ORA1_%s.mat', subjectNum)));
    GCM{i, 3} = load(fullfile(subjectFolder, sprintf('subject_TRA1_%s.mat', subjectNum)));

    % Store the file paths in filePaths
    filePaths{i, 1} = sprintf('subject_FullA1_%s.mat', subjectNum);
    filePaths{i, 2} = sprintf('subject_ORA1_%s.mat', subjectNum);
    filePaths{i, 3} = sprintf('subject_TRA1_%s.mat', subjectNum);
end

save(fullfile(subject_folder, 'filePaths.mat'), 'filePaths', '-v7.3');
save(fullfile(subject_folder, 'GCM.mat'), 'GCM', '-v7.3');
end
