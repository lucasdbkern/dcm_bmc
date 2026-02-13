function bmc_test(dcm_file_path)

Ep = 0.1;
u = 0.05;
erp = 0.5; %1.5 for 'ERP, less for 'CMC'
hE = 6;
hC = 0.03125;

param_key = sprintf('%f_%f_%f_%d_%f', Ep, u, erp, hE, hC);


% Run subjectcreator_erp for each scenario
subjectcreator_erp(dcm_file_path, 'ERP', Ep, u, erp, 1, '', '', '', param_key);
subjectcreator_erp(dcm_file_path, 'ERP', Ep, u, erp, 1, 'oncereducedA1.mat', 'oncereducedA2.mat', 'oncereducedA3.mat', param_key);
subjectcreator_erp(dcm_file_path, 'ERP', Ep, u, erp, 1, 'twicereducedA1.mat', 'twicereducedA2.mat', 'twicereducedA3.mat', param_key);


filename_key = strrep(param_key, '.', '_');  % Replace '.' with '_'
filename1 = sprintf('new_subject__%s_1.mat', filename_key);
filename2 = sprintf('new_subject_oncereducedA1_%s_1.mat', filename_key);
filename3 = sprintf('new_subject_twicereducedA1_%s_1.mat', filename_key);

file_paths = {filename1, filename2, filename3};


% run the Bayesian Model Comparison
bmc2(file_paths, dcm_file_path, {'FullA1.mat', 'FullA2.mat', 'FullA3.mat', 'ORA1.mat', 'ORA2.mat', 'ORA3.mat', 'TRA1.mat', 'TRA2.mat', 'TRA3.mat'}, hE, hC);

