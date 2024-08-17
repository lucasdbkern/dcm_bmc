function hE_comparison()
% Initialize structures to hold the data
data_bmc_B = zeros(3, 3, 5);     % For bmc_B, 3x3 matrices, 6 time points (hE2 to hE6)
data_pebbmr_B = zeros(3, 3, 5);  % For pebbmr_B, 3x3 matrices, 6 time points (hE2 to hE6)

% File names pattern
categories = {'bmc_A', 'pebbmr_A'};
base_filename = 'averagePost_';  % You can modify if necessary

for cat = 1:2
    for hE = 2:6
        % Generate the filename
        filename = sprintf('%s%s_hE%d.mat', base_filename, categories{cat}, hE);
        
        % Load the file
        loaded_data = load(filename);
        
        % Store the data into the respective structure
        if strcmp(categories{cat}, 'bmc_A')
            data_bmc_A(:, :, hE-1) = loaded_data.averagePost;  % or loaded_data.F if F is what you need
        elseif strcmp(categories{cat}, 'pebbmr_A')
            data_pebbmr_A(:, :, hE-1) = loaded_data.Pp;  % or loaded_data.F if F is what you need
        else
            error('Unexpected category');
        end
    end
end

% Save the structures individually
save('data_bmc_A.mat', 'data_bmc_A');
save('data_pebbmr_A.mat', 'data_pebbmr_A');

% Function to plot the 3x3 grid of bar charts for the 5 hE values
function plot_barchart(data, titleText)
    figure;
    for i = 1:3
        for j = 1:3
            subplot(3, 3, (i-1)*3 + j);  % Create a 3x3 grid of subplots

            %bar(squeeze(data(i, j, :)));  % Plot bar chart for the 5 hE values

            current_data = squeeze(data(i, j, :));  % Ensure it's a column vector
            
            % Plot the bar chart for the current grid cell
            bar(2:6, current_data'); 

            %current_data = current_data(:);
            % Plot the bar chart for the current grid
            bar(2:6, current_data);  % x-axis corresponds to 2 to 6
            title(sprintf('Model %d Timeseries %d', i, j));
            xlabel('hE (2-6)');
            ylabel('Probability');
            xlim([1.5 6.5]); 
            ylim([0 1.1]);
        end 
    end
    sgtitle(titleText); % Overall title for the figure
end

% Plot the barcharts for the data structures
plot_barchart(data_bmc_A, 'BMC');
plot_barchart(data_pebbmr_A, 'PEB+BMR');

end
