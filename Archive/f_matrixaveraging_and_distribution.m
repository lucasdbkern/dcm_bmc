function f_matrixaveraging_and_distribution

% Initialize the total number of subjects
numberofsubjects = 0; 
sumF = zeros(3,3); 

% Prepare to collect data for individual element distributions
num_elements = 3; % Assuming a 3x3 matrix
all_elements = cell(num_elements, num_elements); % Cell array to hold distributions for all elements

% Loop through all potential matrix files
for i = 1:5
    filename = sprintf('CMC_FreeEnergyMatrix_%d.mat', i);
    if exist(filename, 'file') == 2 % Check if the file exists
        load(filename, 'F'); 
        numberofsubjects = numberofsubjects + 1; 
        sumF = sumF + F; % Summing all matrices only if the file is loaded
        
        % Collect elements for distribution analysis
        for r = 1:num_elements
            for c = 1:num_elements
                all_elements{r, c} = [all_elements{r, c}, F(r, c)];
            end
        end
    else
        fprintf('File %s not found, skipping...\n', filename);
    end
end

% Calculate the average Free Energy (F) Matrix
averageF = sumF / numberofsubjects;

% Subtract the minimum value in each row from all elements in that row
%for r = 1:num_elements
%    row_min = min(averageF(r, :));
%    averageF(r, :) = averageF(r, :) - row_min;
%end




averageF = averageF - min(averageF, [], 2); 

% Displaying the average matrix as a heatmap
figure;
heatmap(averageF);
title('Average Free Energy (F) Heatmap');
colorbar;

% Display distributions of individual matrix elements
figure;
for r = 1:num_elements
    for c = 1:num_elements
        subplot(num_elements, num_elements, (r-1)*num_elements + c);
        histogram(all_elements{r, c});
        title(sprintf('Distribution of F(%d,%d)', r, c));
        xlabel('Value');
        ylabel('Frequency');
    end
end

% Reporting
timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
disp(['Average Free Energy (F) Matrix as of ', timestamp, ':']);
disp(averageF);
disp(['Total subjects included: ', num2str(numberofsubjects)]);

end
