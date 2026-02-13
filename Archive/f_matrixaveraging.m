function f_matrixaveraging

% Load and average the Free Energy matrices
numberofsubjects =0; 

% Collect data for individual element distributions
all_a11 = []; % Collection of all a1,1 elements
all_a22 = []; % Collection of all a2,2 elements



sumF = zeros(3,3); 
for i = 1:130
    filename = sprintf('FreeEnergyMatrix_%d_y.mat', i);
    if exist(filename, 'file') == 2 % Check if the file exists
        load(filename, 'F'); 
        numberofsubjects = numberofsubjects +1; 
        sumF = sumF + F; % Summing all matrices only if the file is loaded

         % Collect elements for distribution analysis
        all_a11 = [all_a11, F(1,1)];
        all_a22 = [all_a22, F(2,2)];
   
    else
        fprintf('File %s not found, skipping...\n', filename);
    end
end

% Distribution of individual matrix elements
figure;
subplot(1,2,1); % Subplot for a1,1 distribution
histogram(all_a11, 'FaceColor', 'b');
title('Distribution of F(1,1) Values');
xlabel('F(1,1) Value');
ylabel('Frequency');

subplot(1,2,2); % Subplot for a2,2 distribution
histogram(all_a22, 'FaceColor', 'r');
title('Distribution of F(2,2) Values');
xlabel('F(2,2) Value');
ylabel('Frequency');

timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
disp(['Average Free Energy (F) Matrix as of ', timestamp, ':']);
disp(sumF);

disp(numberofsubjects);