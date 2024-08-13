function subjectcreator(dcm_file_path, model_type, noise_magnitude_Ep, noise_magnitude_u, noise_magnitude_erp, Nm, customA1, customA2, customA3, param_key, save_folder, model)
%==========================================================================
%This function generates simulated subjects based on a given DCM file 
%and custom connectivity matrices.
%It does the following main tasks:
% 
% 1. Loads and configures a DCM model
% 2. Applies custom connectivity matrices if provided
% 3. Generates multiple simulated subjects by:
% 
% 4. Adding noise to parameters
% 5. Generating noisy input
% 6. Creating ERPs based on the new models
% 7. processing and validating the generated ERPs
% 
% 
% 8. Saves the generated subject data and plots results
% 
% The function uses a loop to generate the specified number of subjects,
% each with slightly different parameters due to added noise. 
% It ensures that only valid ERPs are saved, and provides visual feedback through plots.
% 
% 
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
M = DCM.M;
spm('defaults', 'eeg');

% Configure DCM
% DCM = spm_dcm_erp_dipfit(DCM);
DCM.M.Nmax =1;
DCM.M.hE = 2;
% DCM.options.Nmodes = 16;

U.dt = DCM.xU.dt;
U.X = DCM.xU.X;


% Load custom matrices if provided

if ~isfile(customA1)
    error('file not found')
end

if ~isfile(customA2)
    error('file not found')
end

if ~isfile(customA3)
    error('file not found')
end

if ~isempty(customA1)
    loadedA1 = load(customA1);
    fields = fieldnames(loadedA1);
    A1 = loadedA1.(fields{1});
    DCM.A{1, 1} = A1;
end
if ~isempty(customA2)
    loadedA2 = load(customA2);
    fields = fieldnames(loadedA2);
    A2 = loadedA2.(fields{1});
    DCM.A{1, 2} = A2;
end
if ~isempty(customA3)
    loadedA3 = load(customA3);
    fields = fieldnames(loadedA3);
    A3 = loadedA3.(fields{1});
    DCM.A{1, 3} = A3;
end

% Update DCM.B if all custom matrices are provided
if ~isempty(customA1) && ~isempty(customA2) && ~isempty(customA3)
    %DCM.B{1, 1} = (~~DCM.B{1, 1})&(DCM.A{1, 1}|DCM.A{1, 2}|DCM.A{1, 3});
    % if only the B matrix should be pruned: 
    DCM.B{1, 1} = (~~DCM.B{1, 1})&(A1|A2|A3);
    switch model
        case 'Full'
            DCM.B{1, 1} = DCM.B{1, 1} + eye(size(DCM.B{1, 1}));  
        case 'ORA'
            DCM.B{1, 1} = DCM.B{1, 1} + eye(size(DCM.B{1, 1}));
            DCM.B{1, 1}(5, 5) = 0;  % Set the (5,5) element to zero
        case 'TRA'
            DCM.B{1, 1}(1, 1) = 1; %only lA1, rA1 have intrinsic connections
            DCM.B{1, 1}(2, 2) = 1;
        otherwise
            error('Invalid model name. Choose "Full", "ORA", or "TRA".');
    end
end

% % Update DCM parameters based on custom matrices
DCM.Ep.B{1, 1} = DCM.Ep.B{1} .*  DCM.B{1, 1} - (1 - DCM.B{1, 1}) .* 0;
DCM.M.pE.B{1, 1} = DCM.M.pE.B{1, 1} .*  DCM.B{1, 1} - (1 - DCM.B{1, 1}) .* 0;
% DCM.M.pC.B{1, 1} = DCM.M.pC.B{1, 1} .*  DCM.B{1, 1}; 
DCM.M.pC.B{1, 1} = 0.125*  DCM.B{1, 1}; 


%comment out if only B matrix is pruned 
for i=1:3
    DCM.Ep.A{1, i} = DCM.Ep.A{i} .*  DCM.A{1, i} - (1 - DCM.A{1, i}) .* 4;
    DCM.M.pE.A{1, i} = DCM.M.pE.A{i} .*  DCM.A{1, i} - (1 - DCM.A{1, i}) .* 4;
    DCM.M.pC.A{1, i} = DCM.M.pC.A{i} .*  DCM.A{1, i}; 
end 


i = 1;

% Creates the subfolder within the save_folder
subfolder = fullfile(save_folder, sprintf('subject_%d', param_key));
if ~exist(subfolder, 'dir')
    mkdir(subfolder);
end

% Set up figure for plotting
spm_figure('GetWin', 'inputs and erps')
clf

% Main loop for generating subjects
i = 1;
while i <= Nm
    % Add noise to parameters
    Pvec = spm_vec(DCM.Ep); 
    sqrtpC = sqrt(spm_vec(DCM.M.pC));
    noise = normrnd(0, 1, [158, 1]) .* sqrtpC; % ERP: 158
    Pvec_noisy = Pvec + (noise_magnitude_Ep * noise); 
    P_noisy = spm_unvec(Pvec_noisy, DCM.Ep);

    % Generate input with noise
    U.u = spm_erp_u((1:M.ns)*U.dt, P_noisy, M);
    noise_u = noise_magnitude_u * randn(size(U.u));
    U.u = U.u + noise_u; 

    % Create temporary DCM and generate ERPs for different models
    DCMtemp = DCM;
    DCMtemp.M.hE = 2;
    DCMtemp.xU.u = U.u;
    DCMtemp.M.P = P_noisy;
    DCMtemp.M.pE = P_noisy;
    DCMtemp.M.pC = spm_unvec(0*spm_vec(DCMtemp.M.pC),DCMtemp.M.pC);
    DCMtemp.M.gC = spm_unvec(0*spm_vec(DCMtemp.M.gC),DCMtemp.M.gC);
    DCMtemp.M.gE = DCMtemp.Eg;
    DCMtemp.name = strcat(DCM.name, '_temp');
    DCMtemp.options.DATA = 0;
    DCMtemp = spm_dcm_erp(DCMtemp);
    erp = DCMtemp.z;
    pst = DCMtemp.xY.pst;

    clear DCMtemp

    % Process ERPs for each condition
    all_erp = {};
    % all_pst = [];
    
    for cond = 1:length(erp)
        y = erp{cond} + (noise_magnitude_erp * randn(size(erp{cond})));
        
        if all(all(y == 0)) || any(any(isnan(y)))
            continue; 
        end

        % If valid ERPs generated, save the subject
        all_erp = [all_erp, y]; % Collecting all erp outputs
    end
    
    %update DCM structure:
    if ~isempty(all_erp)
        % Update DCM structure 
        DCM.xY.y   = all_erp;
        DCM.xY.pst = pst;
        DCM.Ep = P_noisy;


        %plot ERP results
        subplot(3,1,1)
        plot(pst, U.u);
        subplot(3,1,2);
        plot(pst, all_erp{1})
        subplot(3,1,3);
        plot(pst, all_erp{2})
        drawnow
        

        %Generate filename and save DCM 
        % Initialize parts of the filename based on custom matrices
        part1 = '';
        
        % Check if customA1 is not empty and adjust filename part
        if ~isempty(customA1)
            [~, name, ~] = fileparts(customA1); % Extract the name without extension
            part1 = name; % Use the extracted name directly in the filename part
        end

        filename = sprintf('subject_%s_%d.mat', part1, param_key);
        
        % Change DCM name within the file
        DCM.name = filename;

        % Create the full file path
        fullFilePath = fullfile(subfolder, filename);

        % Save the updated DCM structure
        save(fullFilePath, 'DCM', '-v7.3');

        i = i + 1;
        clear DCM
    end
end
