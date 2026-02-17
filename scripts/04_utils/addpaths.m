function addpaths()

% Define the main folder containing all subject folders
mainFolder = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/roving-oddball-dataset/subject_folder/';

% Generate the path for all subfolders within the main folder
allFolders = genpath(mainFolder);

% Add all these folders to MATLAB's search path
addpath(allFolders);

% Save the updated path for future sessions
savepath;

% Display the added paths
disp('The following paths have been added:');
disp(allFolders);