function plot_peb_heatmap()
%==========================================================================
% Visualises PEB+BMR results as free energy and posterior probability heatmaps.
%
% Loads the BMA (Bayesian Model Average) struct output from spm_dcm_peb_bmc
% for each of the three model types (Full, ORA, TRA), assembles them into
% a 3x3 matrix, and displays two heatmaps: one for free energy (F) and one
% for posterior model probabilities (Pp).
%
% Posterior probabilities are taken directly from BMA.P (computed by SPM),
% rather than being recomputed manually. Free energies are min-normalised
% column-wise before display.
%
% Note: supersedes average_F_PEB_heatmap.m and average_F_BMR_heatmap.m,
% which used a manually computed softmax approximation and loaded from a
% different results path. Those files can be safely deleted.
%
% Inputs:  none (paths hardcoded, see results/ directory)
% Outputs: two figures + saves averageF_pebbmr_B_hE6.mat and
%          averagePost_pebbmr_B_hE6.mat to working directory
%
% Dependencies: peb_bmr_results_Full.mat, peb_bmr_results_ORA.mat,
%               peb_bmr_results_TRA.mat (in results/ folder)
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