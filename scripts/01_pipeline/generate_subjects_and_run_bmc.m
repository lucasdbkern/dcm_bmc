function generate_subjects_and_run_bmc(n)
% ===========================================================================
% This script generates multiple subjects and performs BMC for each set.
% Inputs:
% dcm_file_path - File path for the DCM files.
% n - Number of subjects to simulate.
% ==========================================================================

Ep = 0.1;  % Magnitude of noise for Ep
u = 0.25;  % Magnitude of noise for u
erp = 0.015; % Magnitude of noise for erp

% Define the folder where subjects will be saved
%base_folder_A = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder_A';
base_folder_B = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder_B';

% Loop to create files for each subject triple
for hE = 4
    % Generate and save subjects the Modulatory Connectivity Case
    for i = 1:n
        subject_folder_B_hE = fullfile(base_folder_B, sprintf('subject_folder_B_hE%d', hE));
        if ~exist(subject_folder_B_hE, 'dir')
            mkdir(subject_folder_B_hE);
        end

        conn_path = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/connectivity_matrices/';

        simulate_subject(dcm_file_path, 'ERP', 'Bmatrix', hE, Ep, u, erp, 1, ...
            fullfile(conn_path, 'FullA1.mat'), fullfile(conn_path, 'FullA2.mat'), fullfile(conn_path, 'FullA3.mat'), ...
            i, subject_folder_B_hE, 'Full');
        
        simulate_subject(dcm_file_path, 'ERP', 'Bmatrix', hE, Ep, u, erp, 1, ...
            fullfile(conn_path, 'ORA1.mat'), fullfile(conn_path, 'ORA2.mat'), fullfile(conn_path, 'ORA3.mat'), ...
            i, subject_folder_B_hE, 'ORA');
        
        simulate_subject(dcm_file_path, 'ERP', 'Bmatrix', hE, Ep, u, erp, 1, ...
            fullfile(conn_path, 'TRA1.mat'), fullfile(conn_path, 'TRA2.mat'), fullfile(conn_path, 'TRA3.mat'), ...
            i, subject_folder_B_hE, 'TRA');

        % Run the Bayesian Model Comparison for Model B
        run_bmc_per_subject(num2str(i), subject_folder_B_hE);
    end
end



