function average_F_BMR_heatmap()
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
results = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/results/';

% load files 
average_F_full = load(fullfile(results, 'peb_bmr_results_Full.mat'), 'average_F');
average_F_ORA = load(fullfile(results, 'peb_bmr_results_ORA.mat'), 'average_F');
average_F_TRA = load(fullfile(results, 'peb_bmr_results_TRA.mat'), 'average_F');
% average_F_full = load('peb_bmr_results_Full.mat', "average_F");
% average_F_ORA = load("peb_bmr_results_ORA.mat", "average_F");
% average_F_TRA = load("peb_bmr_results_TRA.mat", "average_F");

% Initialize the 3x3 matrix
average_F = zeros(3,3);
Posterior_model_probabilities = zeros(3,3);

% assign average F matrices to 3x3 matrix
average_F(1,:) = average_F_full.average_F';
average_F(2,:) = average_F_ORA.average_F';
average_F(3,:) = average_F_TRA.average_F';

% Display the average matrix as a heatmap
figure;
heatmap(average_F);
title('Average Free Energy (F) Heatmap');
xlabel('Simulated Timeseries');
ylabel('Different Fitted Models');
colorbar;

for i=1:3
    averageF = average_F(:,i);
    P = average_F- max(average_F);
    P = exp(P);
    post = P/sum(P); 
    Posterior_model_probabilities(:,i) = post;
end 

% Round the probabilities for better display
Posterior_model_probabilities = round(Posterior_model_probabilities, 4);




% Display the average matrix as a heatmap
figure;
h = heatmap(Posterior_model_probabilities);
title('Posterior Probability (post) Heatmap');
xlabel('Simulated Timeseries');
ylabel('Fitted Models');
colorbar;

end