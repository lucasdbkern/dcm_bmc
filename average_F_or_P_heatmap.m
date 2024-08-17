function average_F_or_P_heatmap()
%==========================================================================
% This function loads average_F values from three different PEB result files, 
% combines them into a 3x3 matrix, and displays the result as a heatmap.
%
% The function expects three files in the current directory:
% - 'peb_bmr_results_FULL_*.mat'
% - 'peb_bmr_results_ORA_*.mat'
% - 'peb_bmr_results_TRA_*.mat'
% where * is a timestamp.
%==========================================================================
% Define the path to the results folder
results = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/';

% load files 
BMA_full = load(fullfile(results, 'peb_bmr_results_Full.mat'), 'BMA');
BMA_ORA = load(fullfile(results, 'peb_bmr_results_ORA.mat'), 'BMA');
BMA_TRA = load(fullfile(results, 'peb_bmr_results_TRA.mat'), 'BMA');

% Initialize the 3x3 matrix
F = zeros(3,3);
Pp = zeros(3,3);

% assign average F columns to 3x3 matrix
F(:,1) = BMA_full.BMA.F;
F(:,2) = BMA_ORA.BMA.F;
F(:,3) = BMA_TRA.BMA.F;

F = F - min(F, [], 1); 

% assign PP columns to 3x3 matrix
Pp(:,1) = BMA_full.BMA.P;
Pp(:,2) = BMA_ORA.BMA.P;
Pp(:,3) = BMA_TRA.BMA.P;

% Round the probabilities for better display
Pp = round(Pp, 4);


% Display the average matrix as a heatmap
figure;
heatmap(F);
title('Average Free Energy (F) Heatmap');
xlabel('Simulated Timeseries');
ylabel('Different Fitted Models');
colorbar;


% Display the average matrix as a heatmap
figure;
h = heatmap(Pp);
title('PEB+BMR Posterior Probability Heatmap');
xlabel('Simulated Timeseries');
ylabel('Fitted Models');
colorbar;

save(('averageF_pebbmr_B_hE6.mat'), 'F');
save(('averagePost_pebbmr_B_hE6.mat'), 'Pp');
end