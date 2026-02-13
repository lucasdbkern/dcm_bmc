function bmc3(file_paths, dcm_mat_file, customA_files, parameter_hE, parameter_hC, k)
% BMC 
% Ensure to wrap file paths in brackets {file, file2, file3} for proper functionality.

success = true;
errmsg = '';

spm('defaults', 'eeg')

% Number of files/models
n = length(file_paths);

% Loads the DCM struct from the .mat file
l_data = load(dcm_mat_file, 'DCMi');
DCM = l_data.DCMi;

% Initialize arrays to store models, timeseries, and inputs
Ms = cell(n, 1);
Ys = cell(n, 1);
U = DCM.xU;

DCM.M.hE = parameter_hE;

% Update DCM structure for each model
DCM = spm_dcm_erp_dipfit(DCM, 1);

% Load models and timeseries from files
for i = 1:n
    loaded_data = load(file_paths{i});
    Ys{i}.y = loaded_data.DCM.xY.y; % Timeseries

    % Create a copy of the DCM structure for each model
    Ms{i} = loaded_data.DCM;
    Ms{i}.M.dipfit = DCM.M.dipfit;
end

% Update the A matrices with custom files
for j = 1:n
    idx = (j-1) * 3 + 1;
    if length(customA_files) < idx+2
        error('Not enough entries in customA_files to update the model for j = %d. Needed at least %d, found %d.', j, idx+2, length(customA_files));
    end
    Ms{j}.A = cell(1, 3);
    if ~isempty(customA_files{idx})
        loadedA1 = load(customA_files{idx});
        fields = fieldnames(loadedA1);
        A1 = loadedA1.(fields{1});
        Ms{j}.A{1, 1} = A1;
    end
    if ~isempty(customA_files{idx+1})
        loadedA2 = load(customA_files{idx+1});
        fields = fieldnames(loadedA2);
        A2 = loadedA2.(fields{1});
        Ms{j}.A{1, 2} = A2;
    end
    if ~isempty(customA_files{idx+2})
        loadedA3 = load(customA_files{idx+2});
        fields = fieldnames(loadedA3);
        A3 = loadedA3.(fields{1});
        Ms{j}.A{1, 3} = A3;
    end
end

% Adjust the B matrix based on the new A matrices provided
for j = 1:n   
    Ms{j}.B{1, 1} = (~~Ms{j}.B{1, 1}) & (Ms{j}.A{1, 1} | Ms{j}.A{1, 2} | Ms{j}.A{1, 3});
end

% Custom U creation for each model
noise_magnitude_Ep = 0.1; 
noise_magnitude_u = 0.1; 

for i = 1:n
    Pvec = spm_vec(DCM.Ep); 
    sqrtpC = sqrt(diag(DCM.Cp));
    noise = normrnd(0, 1, [158, 1]) .* sqrtpC; % 'ERP' : 158
    Pvec_noisy = Pvec + (noise_magnitude_Ep * noise); 
    P_noisy = spm_unvec(Pvec_noisy, DCM.Ep);
    
    % Create the input time series with added noise
    U.u = spm_erp_u((1:DCM.M.ns) * U.dt, P_noisy, DCM.M);
    noise_u = noise_magnitude_u * randn(size(U.u));
    U.u = U.u + noise_u;
end

% Adjust the priors for each model with the updated A and B matrices
for i = 1:n
    [Ms{i}.M.pE, Ms{i}.M.pC] = spm_dcm_neural_priors(Ms{i}.A, Ms{i}.B, Ms{i}.C, 'ERP');
    Ms{i}.M.m = 1;
        Ms{i}.M.U  = spm_dcm_eeg_channelmodes(Ms{i}.M.dipfit,8);%Nm

end

% Initialize matrices for nested model inversion results
Ep = cell(n, n);
Cp = cell(n, n);
Eh = cell(n, n);
F = zeros(n, n);
L = cell(n, n);

%potentially hash out when using smp_nsli_N
dFdp = cell(n, n);
dFdpp = cell(n, n);


%potentially hash out when using smp_nsli_GN
%Eg = cell(n, n);
%Cg = cell(n, n);
%S = cell(n, n);



% Perform model inversion
for i = 1:n
    for j = 1:n
        disp(['Processing model inversion for M', num2str(i), ' with Y', num2str(j)]);
        
        xY = DCM.xY;
        xY.y = Ys{j}.y;
        
        Ms{i}.M.hC = parameter_hC;
        
       % try 
        %[Ep{i, j}, Cp{i, j}, Eh{i, j}, F(i, j),dFdp{i, j}, dFdpp{i, j}] = spm_nlsi_GN_adjusted(Ms{i}.M, U, xY);
        [Ep{i, j}, Eg{i, j}, Cp{i, j}, Cg{i, j}, S{i, j}, F(i, j), L{i, j}] = spm_nlsi_N(Ms{i}.M, U, xY);
        %catch ME
        %    success = false;
         %   return;
        %end
    end
end


if success
    noise_magnitude_erp = 1.5;
    
    % Display and save the Free Energy (F) matrix
    disp('Free Energy (F) Matrix:')
    filename = sprintf('CMC_FreeEnergyMatrix_%d.mat', k);
    save(filename, 'F');
    
    % Prepare results for visualization
    model_labels = arrayfun(@(i) sprintf('Ys{%d}', i), 1:n, 'UniformOutput', false);
    data_labels = arrayfun(@(i) sprintf('Ms{%d}', i), 1:n, 'UniformOutput', false);
    
    % Creating the heatmap with the labeled rows and columns
    figure;
    heatmap(model_labels, data_labels, F);
    title('Free Energy (F) Heatmap');
    colorbar;
end
