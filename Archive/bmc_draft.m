function bmc(file_paths, dcm_mat_file)
% BMC 
% If you dont put brackets around the file paths {file, file2, fil3} it
% wont work

spm('defaults', 'eeg')

% Number of files/models
n = length(file_paths);

% Loads the DCM struct from the .mat file
l_data = load(dcm_mat_file, 'DCM');
DCM = l_data.DCM;



% Initialize arrays to store models, timeseries, and inputs
Ms = cell(n, 1);
Ys = cell(n, 1);
U = DCM.xU;
DCM = spm_dcm_erp_dipfit(DCM,1);




% Loads models, timeseries, and inputs from files
for i = 1:n
    loaded_data = load(file_paths{i});
    Ms{i} = loaded_data.M; % Model
    Ms{i}.dipfit = DCM.M.dipfit;
    %Ys{i}.y = loaded_data.erp; % Timeseries 
    Ys{i}.y = loaded_data.all_erp; % Timeseries 
    %Ys{i}.y = loaded_data.y; % Timeseries 
    % Update pE and Cp 
    [Ms{i}.pE, Ms{i}.pC] = spm_dcm_neural_priors(DCM.A, DCM.B, DCM.C, 'CMC');
    disp(size(Ys{i}.y))
end

% Initializes matrices for nested model inversion results
Ep = cell(n, n);
Cp = cell(n, n);
Eh = cell(n, n);
F = zeros(n, n);
L = cell(n, n);
dFdp = cell(n, n);
dFdpp = cell(n, n);



% Perform model inversion
for i = 1:n
    for j = 1:n
        %try
            % Display current iteration status
            disp(['Processing model inversion for M', num2str(i), ' with Y', num2str(j)]);
            
            % Perform the model inversion using spm_nlsi_GN function
            xY = DCM.xY;
            xY.y = Ys{j}.y;
            
            

            [Ep{i, j}, Cp{i, j}, Eh{i, j}, F(i, j), L{i, j}, dFdp{i, j}, dFdpp{i, j}] = spm_nlsi_GN(Ms{i}, U, xY);
    
    end
end 


disp('Free Energy (F) Matrix:');
disp(F);


save('FreeEnergyMatrix.mat', 'F');

figure;
heatmap(F);
title('Free Energy (F) Heatmap');
colorbar;


end

