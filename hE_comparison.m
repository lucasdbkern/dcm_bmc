% function hE_comparison()
% % Initialize structures to hold the data
% data_bmc_B = zeros(3, 3, 5);     % For bmc_B, 3x3 matrices, 6 SNR points (hE2 to hE6)
% data_pebbmr_B = zeros(3, 3, 5);  % For pebbmr_B, 3x3 matrices, 6 SNR points (hE2 to hE6)
% 
% % File names pattern
% categories = {'bmc_B', 'pebbmr_B'};
% base_filename = 'averagePost_';  % You can modify if necessary
% 
% for cat = 1:2
%     for hE = 2:6
%         % Generate the filename
%         filename = sprintf('%s%s_hE%d.mat', base_filename, categories{cat}, hE);
% 
%         % Load the file
%         loaded_data = load(filename);
% 
%         % Store the data into the respective structure
%         if strcmp(categories{cat}, 'bmc_B')
%             data_bmc_B(:, :, hE-1) = loaded_data.averagePost;  % or loaded_data.F if F is what you need
%         elseif strcmp(categories{cat}, 'pebbmr_B')
%             data_pebbmr_B(:, :, hE-1) = loaded_data.Pp;  % or loaded_data.F if F is what you need
%         else
%             error('Unexpected category');
%         end
%     end
% end
% 
% % Save the structures individually
% save('data_bmc_B.mat', 'data_bmc_B');
% save('data_pebbmr_B.mat', 'data_pebbmr_B');
% 
% % Function to plot the 3x3 grid of bar charts for the 5 hE values
% function plot_barchart(data, titleText)
%     figure;
%     for i = 1:3
%         for j = 1:3
%             subplot(3, 3, (i-1)*3 + j);  % Create a 3x3 grid of subplots
% 
%             %bar(squeeze(data(i, j, :)));  % Plot bar chart for the 5 hE values
% 
%             current_data = squeeze(data(i, j, :));  % Ensure it's a column vector
% 
%             % Plot the bar chart for the current grid cell
%             bar(2:6, current_data'); 
% 
%             %current_data = current_data(:);
%             % Plot the bar chart for the current grid
%             bar(2:6, current_data);  % x-axis corresponds to 2 to 6
%             title(sprintf('Model %d Timeseries %d', i, j));
%             xlabel('hE');
%             ylabel('Probability');
%             xlim([1.5 6.5]); 
%             ylim([0 1.1]);
%         end 
%     end
%     sgtitle(titleText); % Overall title for the figure
% end
% 
% % Plot the barcharts for the data structures
% plot_barchart(data_bmc_B, 'BMC');
% plot_barchart(data_pebbmr_B, 'PEB+BMR');
% 
% end


function hE_comparison()
    % Initialize structures to hold the data
    data_bmc_B = zeros(3, 3, 5);     % For bmc_B, 3x3 matrices, 5 SNR points (hE2 to hE6)
    data_pebbmr_B = zeros(3, 3, 5);  % For pebbmr_B, 3x3 matrices, 5 SNR points (hE2 to hE6)
    
    % File names pattern
    categories = {'bmc_B', 'pebbmr_B'};
    base_filename = 'averagePost_';  % You can modify if necessary
    
    for cat = 1:2
        for hE = 2:6
            % Generate the filename
            filename = sprintf('%s%s_hE%d.mat', base_filename, categories{cat}, hE);
            
            % Load the file
            loaded_data = load(filename);
            
            % Store the data into the respective structure
            if strcmp(categories{cat}, 'bmc_B')
                data_bmc_B(:, :, hE-1) = loaded_data.averagePost;  % or loaded_data.F if F is what you need
            elseif strcmp(categories{cat}, 'pebbmr_B')
                data_pebbmr_B(:, :, hE-1) = loaded_data.Pp;  % or loaded_data.F if F is what you need
            else
                error('Unexpected category');
            end
        end
    end
    
    % Save the structures individually
    save('data_bmc_B.mat', 'data_bmc_B');
    save('data_pebbmr_B.mat', 'data_pebbmr_B');
    
    % Plot the combined average winning confidence for both methods
    plot_combined_average_confidence(data_bmc_B, data_pebbmr_B);
end

function plot_combined_average_confidence(data_bmc, data_pebbmr)
    % Create a new figure
    figure;
    
    % Define colors for each method
    bmc_color = [0.2 0.6 0.8];  % Blue for BMC
    peb_color = [0.8 0.2 0.2];  % Red for PEB+BMR
    
    % Initialize confidence arrays for each method
    bmc_confidence = zeros(3, 5);  % [3 timeseries × 5 hE values]
    peb_confidence = zeros(3, 5);  % [3 timeseries × 5 hE values]
    
    % Calculate confidence for each timeseries and hE value for both methods
    for ts = 1:3
        for h = 1:5
            % Calculate confidence for BMC
            probs_bmc = squeeze(data_bmc(:, ts, h));
            [max_val, max_idx] = max(probs_bmc);
            % Use just the winner's probability as confidence (0-100%)
            bmc_confidence(ts, h) = max_val;
            
            % Calculate confidence for PEB+BMR
            probs_peb = squeeze(data_pebbmr(:, ts, h));
            [max_val, max_idx] = max(probs_peb);
            % Use just the winner's probability as confidence (0-100%)
            peb_confidence(ts, h) = max_val;
        end
    end
    
    % Calculate average confidence across timeseries for each method
    avg_bmc_confidence = mean(bmc_confidence, 1);
    avg_peb_confidence = mean(peb_confidence, 1);
    
    % Convert to percentage (0-100)
    avg_bmc_confidence = avg_bmc_confidence * 100;
    avg_peb_confidence = avg_peb_confidence * 100;
    
    % Plot average confidence for BMC
    plot(2:6, avg_bmc_confidence, '-', 'Color', bmc_color, 'LineWidth', 2.5);
    hold on;
    
    % Plot average confidence for PEB+BMR
    plot(2:6, avg_peb_confidence, '-', 'Color', peb_color, 'LineWidth', 2.5);
    
    % Format the plot
    grid on;
    xlabel('hE Value', 'FontSize', 12);
    ylabel('Average Selection Confidence (%)', 'FontSize', 12);
    title('BMC vs PEB+BMR: Average Winning Model Confidence', 'FontSize', 14, 'FontWeight', 'bold');
    legend('BMC', 'PEB+BMR', 'Location', 'best');
    
    % Set y-axis limits to 0-100 percentage
    ylim([0 100]);
    
    % Add reference line at 33.3 (equivalent to equal probability for all models)
    yline(33.3, 'k--', 'Equal Probability Threshold', 'LineWidth', 1);
    
    % Add reference line at 50% (strong confidence)
    yline(50, 'k--', 'Strong Confidence', 'LineWidth', 1);
    
    % Find optimal hE value for each method
    [max_bmc, opt_bmc_idx] = max(avg_bmc_confidence);
    [max_peb, opt_peb_idx] = max(avg_peb_confidence);
    
    opt_bmc_hE = opt_bmc_idx + 1;
    opt_peb_hE = opt_peb_idx + 1;
    
    % Add annotations for optimal hE values
    text(opt_bmc_hE, max_bmc + 3, ['BMC Optimal hE = ', num2str(opt_bmc_hE)], ...
        'FontWeight', 'bold', 'Color', bmc_color, 'HorizontalAlignment', 'center');
    
    text(opt_peb_hE, max_peb - 5, ['PEB Optimal hE = ', num2str(opt_peb_hE)], ...
        'FontWeight', 'bold', 'Color', peb_color, 'HorizontalAlignment', 'center');
end