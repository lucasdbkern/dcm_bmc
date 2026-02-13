function process_subjects3()
    subject_folder = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/roving-oddball-dataset/subject_folder';
    folderPattern = fullfile(subject_folder, 'subject_*');
    subfolders = dir(folderPattern);
    
    % Extract and sort subject numbers from folder names
    subjectNumbers = arrayfun(@(x) str2double(regexp(x.name, '\d+', 'match', 'once')), subfolders);
    [~, sortIndex] = sort(subjectNumbers);
    sortedSubfolders = subfolders(sortIndex);
    
    % Load data files and store in GCM
    GCM = arrayfun(@(i) load_subject_data(fullfile(subject_folder, sortedSubfolders(i).name), subjectNumbers(i)), 1:length(sortedSubfolders), 'UniformOutput', false);
    
    disp(GCM);
    save(fullfile(subject_folder, 'GCM3.mat'), 'GCM', '-v7.3');
end

function data = load_subject_data(folder, subjectNum)
    data = cell(1, 3);
    data{1} = load(fullfile(folder, sprintf('subject_FullA1_%d.mat', subjectNum)));
    data{2} = load(fullfile(folder, sprintf('subject_ORA1_%d.mat', subjectNum)));
    data{3} = load(fullfile(folder, sprintf('subject_TRA1_%d.mat', subjectNum)));
end
