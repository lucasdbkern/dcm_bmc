

function multiple_subject_bmc(dcm_file_path, n)
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
base_folder_A = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder_A';
base_folder_B = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder_B';

% Loop to create files for each subject triple
for hE = 3:5
    % Generate and save subjects for Model A
    for i = 1:n
        subject_folder_A_hE = fullfile(base_folder_A, sprintf('subject_folder_A_hE%d', hE));
        if ~exist(subject_folder_A_hE, 'dir')
            mkdir(subject_folder_A_hE);
        end

        subjectcreator(dcm_file_path, 'ERP', Amatrix, hE, Ep, u, erp, 1,'FullA1.mat', 'FullA2.mat', 'FullA3.mat', i, subject_folder_A_hE, 'Full');
        subjectcreator(dcm_file_path, 'ERP', Amatrix, hE, Ep, u, erp, 1, 'ORA1.mat', 'ORA2.mat', 'ORA3.mat', i, subject_folder_A_hE, 'ORA');
        subjectcreator(dcm_file_path, 'ERP', Amatrix, hE, Ep, u, erp, 1, 'TRA1.mat', 'TRA2.mat', 'TRA3.mat', i, subject_folder_A_hE, 'TRA');

        % Run the Bayesian Model Comparison for Model A
        bmc(num2str(i), subject_folder_A_hE);
    end

    % Generate and save subjects for Model B
    for i = 1:n
        subject_folder_B_hE = fullfile(base_folder_B, sprintf('subject_folder_B_hE%d', hE));
        if ~exist(subject_folder_B_hE, 'dir')
            mkdir(subject_folder_B_hE);
        end

        subjectcreator(dcm_file_path, 'ERP', Bmatrix, hE, Ep, u, erp, 1, 'FullA1.mat', 'FullA2.mat', 'FullA3.mat', i, subject_folder_B_hE, 'Full');
        subjectcreator(dcm_file_path, 'ERP', Bmatrix, hE, Ep, u, erp, 1, 'ORA1.mat', 'ORA2.mat', 'ORA3.mat', i, subject_folder_B_hE, 'ORA');
        subjectcreator(dcm_file_path, 'ERP', Bmatrix, hE, Ep, u, erp, 1, 'TRA1.mat', 'TRA2.mat', 'TRA3.mat', i, subject_folder_B_hE, 'TRA');

        % Run the Bayesian Model Comparison for Model B
        bmc(num2str(i), subject_folder_B_hE);
    end
end














% 
% function multiple_subject_bmc(dcm_file_path, n)
% % ===========================================================================
% % This script generates multiple subjects and performs BMC for each set.
% 
% % Inputs:
% 
% % dcm_file_path - File path for the DCM files.
% 
% % n - Number of subjects to simulate.
% 
% 
% %==========================================================================
% 
% Ep = 0.1;  %0.1; %   noise_magnitude_Ep   - Magnitude of noise for Ep
% u = 0.25; %0.45; %   noise_magnitude_u    - Magnitude of noise for u
% erp = 0.015; %0.035; %   noise_magnitude_erp  - Magnitude of noise for erp
% 
% 
% % Loop to create files for each subject triple
% %--------------------------------------------------------------------------
% for hE =2:5
%     for i = 1:n
%         subjectcreator(dcm_file_path, 'ERP', Amatrix,hE, Ep, u, erp, 1, 'FullA1.mat', 'FullA2.mat', 'FullA3.mat', i,'/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder', 'Full');
%         subjectcreator(dcm_file_path, 'ERP',Amatrix,hE, Ep, u, erp, 1, 'ORA1.mat', 'ORA2.mat', 'ORA3.mat', i, '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder','ORA');
%         subjectcreator(dcm_file_path, 'ERP',Amatrix,hE, Ep, u, erp, 1, 'TRA1.mat', 'TRA2.mat', 'TRA3.mat', i, '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder','TRA');
% 
% 
%         % run the Bayesian Model Comparison
%         bmc(num2str(i),'/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder_A')
%     end
% end
% 
% 
% for hE =2:5
%     for i = 1:n
%         subjectcreator(dcm_file_path, 'ERP', Bmatrix,hE, Ep, u, erp, 1, 'FullA1.mat', 'FullA2.mat', 'FullA3.mat', i,'/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder', 'Full');
%         subjectcreator(dcm_file_path, 'ERP',Bmatrix,hE, Ep, u, erp, 1, 'ORA1.mat', 'ORA2.mat', 'ORA3.mat', i, '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder','ORA');
%         subjectcreator(dcm_file_path, 'ERP',Bmatrix,hE, Ep, u, erp, 1, 'TRA1.mat', 'TRA2.mat', 'TRA3.mat', i, '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder','TRA');
% 
% 
%         % run the Bayesian Model Comparison
%         bmc(num2str(i),'/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder_B')
%     end
% end
% 



