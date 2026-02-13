function simple_column3_hE_analysis()
%==========================================================================
% Simple analysis of column 3 (TRA as data source) across hE values
% Uses your existing file structure
%==========================================================================

% First, let's check what files you actually have
fprintf('Checking available files...\n');

% Try different possible file patterns
base_paths = {
    '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/subject_%d/derivatives/DCMij.mat',
    '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/hE_gradual_sensitivity_results_%d.mat',
    '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/dcm_hE4_connection_sensitivity_45_54.mat'
};

% Check which files exist
for i = 1:length(base_paths)
    test_file = sprintf(base_paths{i}, 1);
    if exist(test_file, 'file')
        fprintf('Found files matching pattern: %s\n', base_paths{i});
    else
        fprintf('No files found for pattern: %s\n', base_paths{i});
    end
end

% Let's use your confusion matrix data that we know exists
fprintf('\nUsing existing confusion matrix approach...\n');

% Load one of your existing results to see the structure
try
    % Try to load your existing confusion matrix results
    test_files = {
        'averagePost_bmc_B_hE2.mat', 'averagePost_bmc_B_hE3.mat', 'averagePost_bmc_B_hE4.mat',
        'averagePost_bmc_B_hE5.mat', 'averagePost_bmc_B_hE6.mat'
    };
    
    hE_values = [2, 3, 4, 5, 6];
    column3_data = zeros(3, length(hE_values)); % [fitted_model, hE_value]
    
    for hE_idx = 1:length(hE_values)
        filename = sprintf('averagePost_bmc_B_hE%d.mat', hE_values(hE_idx));
        if exist(filename, 'file')
            data = load(filename);
            if isfield(data, 'averagePost')
                column3_data(:, hE_idx) = data.averagePost(:, 3); % Column 3
                fprintf('Loaded %s\n', filename);
            elseif isfield(data, 'Pp')
                column3_data(:, hE_idx) = data.Pp(:, 3); % Column 3
                fprintf('Loaded %s (Pp field)\n', filename);
            end
        else
            fprintf('File not found: %s\n', filename);
        end
    end
    
    % Plot the results
    figure('Position', [100, 100, 1200, 400]);
    
    % Plot 1: Line plot showing trends
    subplot(1, 2, 1);
    models = {'Full', 'ORA', 'TRA'};
    colors = [0.2 0.4 0.8; 0.8 0.2 0.4; 0.2 0.8 0.4];
    
    for model = 1:3
        plot(hE_values, column3_data(model, :), 'o-', ...
            'Color', colors(model, :), 'LineWidth', 2, 'MarkerSize', 8, ...
            'DisplayName', [models{model} ' → TRA']);
        hold on;
    end
    
    xlabel('hE Value');
    ylabel('Posterior Probability');
    title('Column 3: Models Fitting TRA Data');
    legend('Location', 'best');
    grid on;
    
    % Plot 2: Heatmap
    subplot(1, 2, 2);
    imagesc(column3_data);
    colorbar;
    title('Heatmap: Column 3 Across hE');
    xlabel('hE Value');
    ylabel('Fitted Model');
    set(gca, 'XTick', 1:length(hE_values), 'XTickLabel', hE_values, ...
             'YTick', 1:3, 'YTickLabel', models);
    
    % Add text annotations
    for i = 1:3
        for j = 1:length(hE_values)
            text(j, i, sprintf('%.3f', column3_data(i, j)), ...
                'HorizontalAlignment', 'center', 'FontSize', 10);
        end
    end
    
    sgtitle('Column 3 Analysis: TRA as Data Source', 'FontSize', 14);
    
    % Compute and display correlations
    fprintf('\n=== CORRELATIONS WITH hE ===\n');
    for model = 1:3
        if ~all(column3_data(model, :) == 0)
            [r, p] = corrcoef(hE_values, column3_data(model, :));
            fprintf('%s → TRA: r = %.3f, p = %.3f\n', models{model}, r(1,2), p(1,2));
        end
    end
    
catch ME
    fprintf('Error: %s\n', ME.message);
    fprintf('Let me check what files you actually have...\n');
    
    % List all .mat files in current directory
    files = dir('*.mat');
    fprintf('Available .mat files in current directory:\n');
    for i = 1:length(files)
        fprintf('  %s\n', files(i).name);
    end
    
    % Check results directory
    if exist('results', 'dir')
        files = dir('results/*.mat');
        fprintf('Available .mat files in results directory:\n');
        for i = 1:length(files)
            fprintf('  %s\n', files(i).name);
        end
    end
end

end

function manual_column3_analysis()
%==========================================================================
% Manual version - you input the data directly
%==========================================================================

fprintf('Manual analysis - please input your data:\n');

% Example data structure - replace with your actual values
hE_values = [2, 3, 4, 5, 6];
models = {'Full', 'ORA', 'TRA'};

% Column 3 data: how well each model represents TRA-generated data
% Replace these with your actual values from your heatmaps
column3_data = [
    0.1, 0.15, 0.2, 0.25, 0.3;  % Full → TRA across hE values
    0.3, 0.35, 0.4, 0.45, 0.5;  % ORA → TRA across hE values  
    1.0, 1.0, 1.0, 1.0, 1.0;    % TRA → TRA (should be 1.0 for posterior prob)
];

% Plot
figure('Position', [100, 100, 800, 600]);
colors = [0.2 0.4 0.8; 0.8 0.2 0.4; 0.2 0.8 0.4];

for model = 1:3
    plot(hE_values, column3_data(model, :), 'o-', ...
        'Color', colors(model, :), 'LineWidth', 3, 'MarkerSize', 10, ...
        'DisplayName', [models{model} ' → TRA']);
    hold on;
end

xlabel('hE Value', 'FontSize', 14);
ylabel('Posterior Probability', 'FontSize', 14);
title('Column 3: How Well Can Models Represent TRA Data?', 'FontSize', 16);
legend('Location', 'best', 'FontSize', 12);
grid on;
set(gca, 'FontSize', 12);

% Compute correlations
fprintf('\n=== CORRELATIONS ===\n');
for model = 1:3
    [r, p] = corrcoef(hE_values, column3_data(model, :));
    fprintf('%s → TRA: r = %.3f, p = %.3f\n', models{model}, r(1,2), p(1,2));
end

% Show what this means
fprintf('\n=== INTERPRETATION ===\n');
fprintf('Column 3 = TRA as data source\n');
fprintf('This shows how well each model can represent TRA-generated dynamics\n');
fprintf('As hE increases (less noise), do models get better/worse at representing TRA?\n');

end