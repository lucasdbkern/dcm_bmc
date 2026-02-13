function test_convergence(dcm_file_path)
% Define parameter ranges and sets
Ep_intervals = linspace(0, 0.3, 100); % interval for noise_magnitude_Ep
u_intervals = linspace(0, 0.5, 100); % interval for noise_magnitude_u
erp_intervals = linspace(0, 1, 100); %  interval for noise_magnitude_erp
hE_values = 3:9; % Set of hE values
hC_intervals = linspace(0.0078125, 0.03125, 100); % interval for hC

% Number of initial tests and retests
num_initial_tests = 2;
num_retests = 2;

% Data structures for tracking and retesting
tested_combinations = containers.Map;
successful_combinations = containers.Map;

% Run initial tests
test_count = 0;
while test_count < num_initial_tests
    % Randomly select parameters
    Ep = randsample(Ep_intervals, 1);
    u = randsample(u_intervals, 1);
    erp = randsample(erp_intervals, 1);
    hE = randsample(hE_values, 1);
    hC = randsample(hC_intervals, 1);

    % Generate a unique key for the parameter combination
    param_key = sprintf('%f_%f_%f_%d_%f', Ep, u, erp, hE, hC);

    % Check if this combination has already been tested
    if isKey(tested_combinations, param_key)
        continue; % Skip this iteration if the combination was already tested
    else
        tested_combinations(param_key) = true; % Mark this combination as tested
        test_count = test_count + 1; % Increment the test counter
    end

   
    % Run subjectcreator_erp for each scenario
    subjectcreator_erp(dcm_file_path, 'ERP', Ep, u, erp, 1, '', '', '', param_key);
    subjectcreator_erp(dcm_file_path, 'ERP', Ep, u, erp, 1, 'oncereducedA1.mat', 'oncereducedA2.mat', 'oncereducedA3.mat', param_key);
    subjectcreator_erp(dcm_file_path, 'ERP', Ep, u, erp, 1, 'twicereducedA1.mat', 'twicereducedA2.mat', 'twicereducedA3.mat', param_key);

    test_count = test_count+1; 
end

param_keys = keys(tested_combinations);

% Perform Bayesian model comparison
for i = 1:numel(param_keys)
    p_key = param_keys{i}; 


    filename_key = strrep(p_key, '.', '_');  % Replace '.' with '_'
    filename1 = sprintf('new_subject__%s_1.mat', filename_key);
    filename2 = sprintf('new_subject_oncereducedA1_%s_1.mat', filename_key);
    filename3 = sprintf('new_subject_twicereducedA1_%s_1.mat', filename_key);

    file_paths = {filename1, filename2, filename3};

    %do the BMC
    if exist(filename1, 'file') == 2 && exist(filename2, 'file') == 2 && exist(filename3, 'file') == 2
        [success, errmsg] = bmc2(file_paths, 'DCM_30-Apr-2024.mat', {'FullA1.mat', 'FullA2.mat', 'FullA3.mat', 'ORA1.mat', 'ORA2.mat', 'ORA3.mat', 'TRA1.mat', 'TRA2.mat', 'TRA3.mat'}, hE, hC);
        if success
            fprintf('Test %d: Success - %s\n', test_count, p_key);
            successful_combinations(p_key) = struct('Ep', Ep, 'u', u, 'erp', erp, 'hE', hE, 'hC', hC);
        else
            fprintf('Test %d: Failed - %s - %s\n', test_count, p_key, errmsg);
        end
    end         
end


 








    % Loop over all successful parameter combinations
for p_key = keys(successful_combinations)
    param = successful_combinations(p_key{1});

    % Run additional simulations
    for scenario = 1:3
        % Define the file scenario suffixes
        switch scenario
            case 1
                file_suffix = '';
            case 2
                file_suffix = 'oncereducedA1';
            case 3
                file_suffix = 'twicereducedA1';
        end
    end
       
    % Call Bayesian model comparison for each retest
    for retest_num = 1:num_retests
        % Collect the file paths for the current retest number across all scenarios
        current_file_paths = {file_paths{1, retest_num}, file_paths{2, retest_num}, file_paths{3, retest_num}};
        
        % Check if all files exist before calling bmc2
        if exist(current_file_paths{1}, 'file') == 2 && exist(current_file_paths{2}, 'file') == 2 && exist(current_file_paths{3}, 'file') == 2
            [success] = bmc2(current_file_paths, 'DCM_30-Apr-2024.mat', {'FullA1.mat', 'FullA2.mat', 'FullA3.mat', 'ORA1.mat', 'ORA2.mat', 'ORA3.mat', 'TRA1.mat', 'TRA2.mat', 'TRA3.mat'}, param.hE, param.hC);
            if success
                fprintf('Retest %d: Success - %s\n', retest_num, p_key{1});
            else
                printf('Retest %d: Failed - File(s) not found - %s\n', retest_num, p_key{1});
            end
        end 
    end 
end 
% Save both successful and unsuccessful parameter combinations to .mat files
save('successful_combinations.mat', 'successful_combinations');
save('tested_combinations.mat', 'tested_combinations');

    
    