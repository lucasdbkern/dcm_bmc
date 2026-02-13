% function mahalanobis_distance()
% 
% % Load DCM data
% for subj = 1:20
%     subject_folder = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder', sprintf('subject_%d', subj));
%     dcm_data = load(fullfile(subject_folder, 'derivatives', 'DCMij.mat'));
%     DCM_full{subj} = dcm_data.DCMij{1,1};
%     DCM_ora{subj} = dcm_data.DCMij{2,2};
%     DCM_tra{subj} = dcm_data.DCMij{3,3};
% end
% 
% % Calculate mean channel-wise Mahalanobis distance
% M_distance = zeros(20, 3);
% 
% for s = 1:20
%     % Full vs ORA
%     Ce_pooled = 0.5 * (DCM_full{s}.Ce + DCM_ora{s}.Ce);  % Pool covariances
%     Ce_inv = inv(Ce_pooled);                             % Invert to get precision matrix
%     channel_dist = [];
%     for cond = 1:length(DCM_full{s}.H)
%         H_diff = DCM_full{s}.H{cond} - DCM_ora{s}.H{cond}; % Difference matrix: 58×9
%         for ch = 1:size(H_diff, 2)                         % Loop over 9 channels
%             e_ch = H_diff(:, ch);                           % Extract time series for channel ch: 58×1
%             d_ch = sqrt(e_ch' * Ce_inv * e_ch);             % Mahalanobis distance for this channel
%             channel_dist = [channel_dist, d_ch];            % Collect distances
%         end
%     end
%     M_distance(s,1) = mean(channel_dist);                   % Mean across all channels
% 
%     % Full vs TRA  
%     Ce_pooled = 0.5 * (DCM_full{s}.Ce + DCM_tra{s}.Ce);
%     Ce_inv = inv(Ce_pooled);
%     channel_dist = [];
%     for cond = 1:length(DCM_full{s}.H)
%         H_diff = DCM_full{s}.H{cond} - DCM_tra{s}.H{cond};
%         for ch = 1:size(H_diff, 2)
%             e_ch = H_diff(:, ch);
%             d_ch = sqrt(e_ch' * Ce_inv * e_ch);
%             channel_dist = [channel_dist, d_ch];
%         end
%     end
%     M_distance(s,2) = mean(channel_dist);
% 
%     % ORA vs TRA
%     Ce_pooled = 0.5 * (DCM_ora{s}.Ce + DCM_tra{s}.Ce);
%     Ce_inv = inv(Ce_pooled);
%     channel_dist = [];
%     for cond = 1:length(DCM_ora{s}.H)
%         H_diff = DCM_ora{s}.H{cond} - DCM_tra{s}.H{cond};
%         for ch = 1:size(H_diff, 2)
%             e_ch = H_diff(:, ch);
%             d_ch = sqrt(e_ch' * Ce_inv * e_ch);
%             channel_dist = [channel_dist, d_ch];
%         end
%     end
%     M_distance(s,3) = mean(channel_dist);
% end
% 
% % Plot without Statistics Toolbox
% figure;
% bar(mean(M_distance));
% hold on;
% errorbar(1:3, mean(M_distance), std(M_distance), 'k.', 'LineWidth', 1.5);
% set(gca, 'XTickLabel', {'Full vs ORA', 'Full vs TRA', 'ORA vs TRA'});
% ylabel('Mean Mahalanobis Distance');
% title('Channel-wise Mahalanobis Distance');
% xtickangle(45);
% 
% end
function mahalanobis_distance()

% Load DCM data
for subj = 1:20
    subject_folder = fullfile('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder', sprintf('subject_%d', subj));
    dcm_data = load(fullfile(subject_folder, 'derivatives', 'DCMij.mat'));
    DCM_full{subj} = dcm_data.DCMij{1,1};
    DCM_ora{subj} = dcm_data.DCMij{2,2};
    DCM_tra{subj} = dcm_data.DCMij{3,3};
end

% Calculate mean channel-wise Mahalanobis distance
M_distance = zeros(20, 3);

for s = 1:20
    % Full vs ORA
    Ce_pooled = 0.5 * (DCM_full{s}.Ce + DCM_ora{s}.Ce);  % Pool covariances
    Ce_inv = inv(Ce_pooled);                             % Invert to get precision matrix
    channel_dist = [];
    for cond = 1:length(DCM_full{s}.H)
        H_diff = DCM_full{s}.H{cond} - DCM_ora{s}.H{cond}; % Difference matrix: 58×9
        for ch = 1:size(H_diff, 2)                         % Loop over 9 channels
            e_ch = H_diff(:, ch);                           % Extract time series for channel ch: 58×1
            d_ch = sqrt(e_ch' * Ce_inv * e_ch);             % Mahalanobis distance for this channel
            channel_dist = [channel_dist, d_ch];            % Collect distances
        end
    end
    M_distance(s,1) = mean(channel_dist);                   % Mean across all channels
    
    % Full vs TRA  
    Ce_pooled = 0.5 * (DCM_full{s}.Ce + DCM_tra{s}.Ce);
    Ce_inv = inv(Ce_pooled);
    channel_dist = [];
    for cond = 1:length(DCM_full{s}.H)
        H_diff = DCM_full{s}.H{cond} - DCM_tra{s}.H{cond};
        for ch = 1:size(H_diff, 2)
            e_ch = H_diff(:, ch);
            d_ch = sqrt(e_ch' * Ce_inv * e_ch);
            channel_dist = [channel_dist, d_ch];
        end
    end
    M_distance(s,2) = mean(channel_dist);
    
    % ORA vs TRA
    Ce_pooled = 0.5 * (DCM_ora{s}.Ce + DCM_tra{s}.Ce);
    Ce_inv = inv(Ce_pooled);
    channel_dist = [];
    for cond = 1:length(DCM_ora{s}.H)
        H_diff = DCM_ora{s}.H{cond} - DCM_tra{s}.H{cond};
        for ch = 1:size(H_diff, 2)
            e_ch = H_diff(:, ch);
            d_ch = sqrt(e_ch' * Ce_inv * e_ch);
            channel_dist = [channel_dist, d_ch];
        end
    end
    M_distance(s,3) = mean(channel_dist);
end

% Manual boxplot without Statistics Toolbox
figure;
comp_names = {'Full vs ORA', 'Full vs TRA', 'ORA vs TRA'};

for i = 1:3
    data = M_distance(:,i);
    
    % Calculate boxplot statistics
    q1 = quantile(data, 0.25);
    median_val = median(data);
    q3 = quantile(data, 0.75);
    iqr = q3 - q1;
    lower_whisker = max(min(data), q1 - 1.5*iqr);
    upper_whisker = min(max(data), q3 + 1.5*iqr);
    outliers = data(data < lower_whisker | data > upper_whisker);
    
    % Plot box
    box_width = 0.3;
    x_center = i;
    rectangle('Position', [x_center-box_width/2, q1, box_width, iqr], ...
              'EdgeColor', 'k', 'LineWidth', 1.5);
    
    % Plot median line
    line([x_center-box_width/2, x_center+box_width/2], [median_val, median_val], ...
         'Color', 'r', 'LineWidth', 2);
    
    % Plot whiskers
    line([x_center, x_center], [q3, upper_whisker], 'Color', 'k', 'LineWidth', 1);
    line([x_center, x_center], [q1, lower_whisker], 'Color', 'k', 'LineWidth', 1);
    line([x_center-0.1, x_center+0.1], [upper_whisker, upper_whisker], 'Color', 'k', 'LineWidth', 1);
    line([x_center-0.1, x_center+0.1], [lower_whisker, lower_whisker], 'Color', 'k', 'LineWidth', 1);
    
    % Plot outliers
    if ~isempty(outliers)
        scatter(repmat(x_center, length(outliers), 1), outliers, 30, 'r', 'filled');
    end
end

set(gca, 'XTick', 1:3, 'XTickLabel', comp_names);
ylabel('Mahalanobis Distance');
title('Channel-wise Mahalanobis Distance');
xlim([0.5, 3.5]);
xtickangle(45);

end