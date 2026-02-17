function inspect_subject_free_energies()
%==========================================================================
% Loads and inspects free energy values from the 3x3 DCMij confusion matrix
% across all subjects, for diagnostic and exploratory purposes.
%
% For each subject, loads DCMij.mat from derivatives/ and extracts the free
% energy F from every cell of the 3x3 matrix (model i fitted to timeseries j).
% Stores per-subject values in a 3x3xN array, computes the group mean, and
% displays a heatmap and per-element histograms.
%
% Use this to visually inspect subject-level variability, identify outliers,
% and verify the data before running pipeline outputs. Outlier detection via
% IQR is implemented but currently commented out — uncomment to activate.
%
% Inputs:  none (subject path hardcoded)
% Outputs: heatmap of group-mean free energy, 3x3 grid of per-element
%          histograms, printed summary to console
%
% Dependencies: DCMij.mat in subject_<N>/derivatives/ for all subjects
% See also: plot_bmc_confusion_matrix.m (for final pipeline output)
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

disp(sortedSubfolders);

% Initialize the sum matrix
averageF = zeros(3, 3);

% Initialize a 3x3xN matrix to store individual values for each element
elementValues = zeros(3, 3, numSubjects);

% Store subject IDs for outliers identification
subjectIDs = cell(3, 3);

for i = 1:numSubjects
    for j = 1:3
        for k = 1:3
            subjectFolder = fullfile(subject_folder, sortedSubfolders(i).name);

            % Correctly load the .mat file
            matFilePath = fullfile(subjectFolder, 'derivatives', 'DCMij.mat');
            loadedData = load(matFilePath);

            % Access the structure and the required field
            entry = loadedData.DCMij{j, k}.F;
            averageF(j, k) = averageF(j, k) + entry;

            % Store individual values
            elementValues(j, k, i) = entry;
        end
    end
end

% 
% % % % Identify and exclude outliers using IQR
% outlierIndices = false(3, 3, numSubjects);
% for r = 1:3
%     for c = 1:3
%         values = squeeze(elementValues(r, c, :));
%         Q1 = quantile(values, 0.25);
%         Q3 = quantile(values, 0.75);
%         IQR = Q3 - Q1;
%         lowerBound = Q1 - 1.5 * IQR;
%         upperBound = Q3 + 1.5 * IQR;
%         outliers = values < lowerBound | values > upperBound;
%         outlierIndices(r, c, :) = outliers;
%         subjectIDs{r, c} = find(outliers);
%         elementValues(r, c, outliers) = NaN; % Mark outliers as NaN
%     end
% end
% 


% Recompute the average excluding NaNs
averageF = nanmean(elementValues, 3);

%averageF = averageF -  min(averageF,[],1);

% Displaying the adjusted average matrix as a heatmap
figure;
heatmap(averageF);
title('Adjusted Average Free Energy (F) Heatmap (excluding outliers)');
xlabel('Different Timeseries (Columns, j)');
ylabel('Different Base DCM Models (Rows, i)');
colorbar;

% Display distributions of individual matrix elements excluding outliers
figure;
numBins = 50; % Increase the number of bins for a more fine-grained histogram
for r = 1:3
    for c = 1:3
        subplot(3, 3, (r-1)*3 + c);
        histogram(squeeze(elementValues(r, c, :)), numBins);
        title(sprintf('Distribution of F(%d,%d)', r, c));
        xlabel('Value');
        ylabel('Frequency');
    end
end

% Reporting
timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
disp(['Adjusted Average Free Energy (F) Matrix as of ', timestamp, ':']);
disp(averageF);
disp(['Total subjects included: ', num2str(numSubjects)]);
disp('Outliers identified in each element:');
for r = 1:3
    for c = 1:3
        disp(['F(', num2str(r), ',', num2str(c), '): Subjects ', num2str(subjectIDs{r, c}')]);
    end
end

end






