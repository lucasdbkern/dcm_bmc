function hE_comparison()
% Initialize structures to hold the data
data_bmc_B = zeros(3, 3, 6);     % For bmc_B, 3x3 matrices, 6 time points (hE2 to hE6)
data_pebbmr_B = zeros(3, 3, 6);  % For pebbmr_B, 3x3 matrices, 6 time points (hE2 to hE6)

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
            data_bmc_B(:, :, hE-1) = loaded_data.Pp;  % or loaded_data.F if F is what you need
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

end