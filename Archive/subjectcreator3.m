function subjectcreator3(dcm_file_path, model_type, noise_magnitude_Ep, noise_magnitude_u, noise_magnitude_erp, Nm, customA1, customA2, customA3, param_key, save_folder)
%==========================================================================
% Inputs:
%   dcm_file_path        - File path for the DCM file
%   model_type           - Model type for simulation
%   noise_magnitude_Ep   - Magnitude of noise for Ep
%   noise_magnitude_u    - Magnitude of noise for u
%   noise_magnitude_erp  - Magnitude of noise for erp
%   Nm                   - Number of subjects to simulate
%   customA1, customA2, customA3 - Custom matrices to replace A{1,1}, A{1,2}, A{1,3}
%   param_key            - Parameter key for naming files
%   save_folder          - Folder path to save the generated files
%==========================================================================

% Load the DCM file
load(dcm_file_path, 'DCM');
spm('defaults', 'eeg');

% Configure DCM
DCM = spm_dcm_erp_dipfit(DCM);
DCM.M.dipfit.type = model_type;
DCM.M.dipfit.modality = model_type;
DCM.M.dipfit.Ns = 1;
DCM.M.dipfit.Nc = 1;
U.dt = DCM.xU.dt;
U.X = DCM.xU.X;

% Load custom matrices if provided
if ~isempty(customA1) && isfile(customA1)
    loadedA1 = load(customA1);
    fields = fieldnames(loadedA1);
    A1 = loadedA1.(fields{1});
    DCM.A{1, 1} = A1;
end
if ~isempty(customA2) && isfile(customA2)
    loadedA2 = load(customA2);
    fields = fieldnames(loadedA2);
    A2 = loadedA2.(fields{1});
    DCM.A{1, 2} = A2;
end
if ~isempty(customA3) && isfile(customA3)
    loadedA3 = load(customA3);
    fields = fieldnames(loadedA3);
    A3 = loadedA3.(fields{1});
    DCM.A{1, 3} = A3;
end

% Update DCM.B if all custom matrices are provided
if ~isempty(customA1) && ~isempty(customA2) && ~isempty(customA3)
    DCM.B{1, 1} = (~~DCM.B{1, 1}) & (DCM.A{1, 1} | DCM.A{1, 2} | DCM.A{1, 3});
end

i = 1;

% Creates the subfolder within the save_folder
subfolder = fullfile(save_folder, sprintf('subject_%d', param_key));
if ~exist(subfolder, 'dir')
    mkdir(subfolder);
end

while i <= Nm
    % Creates a deepcopy of DCM for each iteration
    DCMtemp = DCM; 
    
    Pvec = spm_vec(DCMtemp.Ep); 
    sqrtpC = sqrt(spm_vec(DCMtemp.M.pC));
    noise = normrnd(0, 1, [158, 1]) .* sqrtpC; % ERP: 158
    Pvec_noisy = Pvec + (noise_magnitude_Ep * noise); 
    P_noisy = spm_unvec(Pvec_noisy, DCMtemp.Ep);
    
    U.u = spm_erp_u((1:DCM.M.ns) * U.dt, P_noisy, DCM.M);
    noise_u = noise_magnitude_u * randn(size(U.u));
    U.u = U.u + noise_u; 

    DCMtemp.M.hE = 6;
    DCMtemp.xU.u = U.u;
    DCMtemp.M.P = P_noisy;
    DCMtemp.M.pC = spm_unvec(0 * spm_vec(DCMtemp.M.pC), DCMtemp.M.pC);
    DCMtemp.M.gC = spm_unvec(0 * spm_vec(DCMtemp.M.gC), DCMtemp.M.gC);
    DCMtemp.M.Nmax = 1;
    DCMtemp.M.gE = DCMtemp.Eg;
    DCMtemp = spm_dcm_erp(DCMtemp);
    erp = DCMtemp.H;
    pst = DCMtemp.xY.pst;

    all_erp = {};
    all_pst = [];
    
    for cond = 1:length(erp)
        y = erp{cond} + (noise_magnitude_erp * randn(size(erp{cond})));
        
        if all(all(y == 0)) || any(any(isnan(y)))
            continue; 
        end
  
        all_erp = [all_erp, y]; % Collecting all erp outputs
        all_pst = [all_pst, pst]; % Collecting time stamps
    end
    
    if ~isempty(all_erp)
        % Update DCM structure 
        DCMi = DCM;
        DCMi.xY.y = all_erp;
        DCMi.xY.pst = all_pst;
        DCMi.xU = U;
        DCMi.M = DCM.M;
        DCMi.Ep = P_noisy;

        % Initialize parts of the filename based on custom matrices
        part1 = '';
        
        % Check if customA1 is not empty and adjust filename part
        if ~isempty(customA1)
            [~, name, ~] = fileparts(customA1); % Extract the name without extension
            part1 = name; % Use the extracted name directly in the filename part
        end

        filename = sprintf('subject_%s_%d.mat', part1, param_key);
        
        % Change DCM name within the file
        DCMi.name = filename;

        % Create the full file path
        fullFilePath = fullfile(subfolder, filename);

        % Save the updated DCM structure
        save(fullFilePath, 'DCMi', '-v7.3');

        i = i + 1;
    end
end

