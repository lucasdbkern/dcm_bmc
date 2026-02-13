function subjectcreator_erp(dcm_file_path, model_type, noise_magnitude_Ep, noise_magnitude_u, noise_magnitude_erp, Nm, customA1, customA2, customA3, param_key)
%==========================================================================

% Inputs:
%   dcm_file_path        - File path for the DCM file
%   model_type           - Model type for simulation
%   noise_magnitude_Ep   - Magnitude of noise for Ep
%   noise_magnitude_u    - Magnitude of noise for u
%   noise_magnitude_erp  - Magnitude of noise for erp
%   Nm                   - Number of subjects to simulate
%   customA1, customA2, customA3 - Custom matrices to replace A{1,1}, A{1,2}, A{1,3}

%==========================================================================

load(dcm_file_path, 'DCM');
M = DCM.M;
spm('defaults', 'eeg')
M.dipfit.type = model_type;
M.dipfit.modality = model_type;
M.dipfit.Ns = 1;
M.dipfit.Nc = 1;
%U.dt = 0.004;
U.dt = DCM.xU.dt;
U.X = DCM.xU.X;
Y.dt = DCM.xY.dt;

if ~isempty(customA1) && isfile(customA1)
    load(customA1)
    DCM.A{1, 1} = customA1;
end
if ~isempty(customA2) && isfile(customA2)
    load(customA2)
    DCM.A{1, 2} = customA2;
end
if ~isempty(customA3) && isfile(customA3)
    load(customA3)
    DCM.A{1, 3} = customA3;
end

if ~isempty(customA1) && ~isempty(customA2) && ~isempty(customA3)
    DCM.B{1, 1} = (~~DCM.B{1, 1})&(DCM.A{1, 1}|DCM.A{1, 2}|DCM.A{1, 3});
end 


i = 1;
total_erp_sums = [];

while i <= Nm
    
    Pvec = spm_vec(DCM.Ep); 
    %sqrtpC = sqrt(diag(DCM.Cp));
    sqrtpC = sqrt(spm_vec(DCM.M.pC));
    noise = normrnd(0, 1, [158, 1]) .* sqrtpC; % ERP: 158
    Pvec_noisy = Pvec + (noise_magnitude_Ep * noise); 
    P_noisy = spm_unvec(Pvec_noisy, DCM.Ep);
    
    U.u = spm_erp_u((1:M.ns)*U.dt, P_noisy, M);
    noise_u = noise_magnitude_u * randn(size(U.u));
    U.u = U.u + noise_u; 

    [erp, pst] = spm_gen_erp(P_noisy, M, U); 

    all_erp = {};
    all_pst = [];
    
    for cond = 1:length(erp)
        y = erp{cond} + (noise_magnitude_erp * randn(size(erp{cond})));
        
   
        if all(all(y == 0)) || any(any(isnan(y)))
            continue; 
        end
        


        all_erp = [all_erp, y]; % Collecting all erp outputs
        all_pst = [all_pst, pst]; % Collecting time stamps




          % Plotting ERP for the current participant and condition
        figure; 
        plot(pst, y, 'b');
        title(sprintf('ERP: Participant %d, Condition %d', i, cond), 'FontSize', 16);

        % Plotting U.u time series for the current participant
        figure; 
        plot((1:M.ns)*U.dt, U.u);
        title(sprintf('U.u Time Series: Participant %d', i), 'FontSize', 16);
        xlabel('Time (s)');
        ylabel('Input Signal');

        total_erp_sum = sum(sum(abs(y)));
        total_erp_sums = [total_erp_sums; total_erp_sum];
    end
    
    if ~isempty(all_erp)


        % Initialize parts of the filename based on custom matrices
        part1 = '';
        
        % Check if customA1 is not empty and adjust filename part
        if ~isempty(customA1)
            [~, name, ~] = fileparts(customA1); % Extract the name without extension
            part1 = name; % Use the extracted name directly in the filename part
        end
        
        if isempty(param_key)
            filename = sprintf('new_subject_%s_%d.mat', part1, i);
        else 
            filename_key = strrep(param_key, '.', '_'); 
            filename = sprintf('new_subject_%s_%s_%d', part1, filename_key, i);
        end
        
        %return filename;


        % Save data for the current participant
        save(filename, 'M', 'P_noisy', 'all_erp', 'all_pst', 'U', '-v7.3');

        % Increment the subject index only after successful save
        i = i + 1;

    end
end

%subjects = (1:length(total_erp_sums))';
%total_erp_sums_table = table(subjects, total_erp_sums, 'VariableNames', {'Participant', 'Total_ERP_Sum'});
%disp(total_erp_sums_table);

%figure;
%bar(subjects, total_erp_sums);
%title('Total ERP Sums for Each Subject');
%xlabel('Subject');
%ylabel('Total ERP Sum');

%end

