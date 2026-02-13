function multiple_subject_bmc_analysis(dcm_file_path, n)

Ep = 0.1;
u = 0.03; %0.1
erp = 1.5; % 1.5 for 'ERP', less for 'CMC'
hE = 4;
hC = 0.03125;
% hC = 0.0078;               %0.03125;
k=1;

file_paths = cell(n, 3); % Preallocate to hold all file paths

% Loop to create files for each subject triple
%--------------------------------------------------------------------------
for i = 1:n
    param_key = sprintf('%f_%f_%f_%d_%f_%d', Ep, u, erp, hE, hC, i);
    subjectcreator(dcm_file_path, 'ERP', Ep, u, erp, 1, '', '', '', param_key);
    subjectcreator(dcm_file_path, 'ERP', Ep, u, erp, 1, 'ORA1.mat', 'ORA2.mat', 'ORA3.mat', param_key);
    subjectcreator(dcm_file_path, 'ERP', Ep, u, erp, 1, 'TRA1.mat', 'TRA2.mat', 'TRA3.mat', param_key);

    filename_key = strrep(param_key, '.', '_'); % Replace '.' with '_'
    filename1 = sprintf('new_subject__%s_1.mat', filename_key);
    filename2 = sprintf('new_subject_ORA1_%s_1.mat', filename_key);
    filename3 = sprintf('new_subject_TRA1_%s_1.mat', filename_key);
    file_paths = {filename1, filename2, filename3};


    % run the Bayesian Model Comparison
    bmc(file_paths, dcm_file_path, {'FullA1.mat', 'FullA2.mat', 'FullA3.mat', 'ORA1.mat', 'ORA2.mat', 'ORA3.mat', 'TRA1.mat', 'TRA2.mat', 'TRA3.mat'}, hE, hC, k);
    k= k+1;
end


% Load and average the Free Energy matrices
sumF = zeros(3,3); 
successful_loads = 0; 
for i = 1:n
    filename = sprintf('CMC_FreeEnergyMatrix_%d.mat', i);
    if exist(filename, 'file') == 2 % Check if the file exists
        load(filename, 'F'); 
        sumF = sumF + F; % Summing all matrices only if the file is loaded
        successful_loads = successful_loads + 1; 
    else
        fprintf('File %s not found, skipping...\n', filename);
    end
end


averageF = sumF / n; % Compute average

timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
disp(['Average Free Energy (F) Matrix as of ', timestamp, ':']);
disp(averageF);

filename_averageF = sprintf('AverageFreeEnergyMatrix_%s.mat', datestr(now, 'yyyy-mm-dd_HHMMSS'));
save(filename_averageF, 'averageF');

total_skips = n - successful_loads;
skip_ratio = total_skips / n;
fprintf('Skipped %d out of %d files (%.2f%%).\n', total_skips, n, skip_ratio * 100);

  