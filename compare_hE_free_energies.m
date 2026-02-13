function compare_hE_free_energies()
%==========================================================================
% Compares Free Energy estimates from BMC and BMR across different hE values
%==========================================================================

% Load results
results = load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/hE_gradual_sensitivity_results_7.mat');
%results = load("hE_sensitivity_analysis_results.mat");
DCMs = results.DCMs;
%hE_values = results.hE_values;
hE_values = [2,3,4,5,6];
strengths = [0,0.5,1,1.5,2,2.5,3,3.5,4];
%strengths = results.strengths;

% Get dimensions
n_strengths = length(strengths);
n_hE = length(hE_values);

% Initialize storage
bmr_F = zeros(n_strengths, n_hE);
bmc_F = zeros(n_strengths, n_hE);

% Calculate Free Energies for each hE value
for hE_idx = 1:n_hE
    % Get reference model for this hE
    ref_DCM = DCMs{1,hE_idx};
    
    % Extract posteriors and priors of reference model
    qE = ref_DCM.Ep;
    qC = ref_DCM.Cp;
    pE = ref_DCM.M.pE;
    pC = ref_DCM.M.pC;
    
    % Calculate BMR and BMC for each strength
    for str_idx = 1:n_strengths
        % Get current DCM
        curr_DCM = DCMs{str_idx,hE_idx};
        
        % Calculate BMR estimate
        [~,rC,rE] = spm_find_pC(curr_DCM);
        [bmr_F(str_idx,hE_idx),~,~] = spm_log_evidence_reduce(qE,qC,pE,pC,rE,rC);
        
        % Get BMC estimate (relative to reference)
        bmc_F(str_idx,hE_idx) = curr_DCM.F - ref_DCM.F;
    end
end


figure; hold on;
% Choose a colormap for distinct colors per hE value
colors = lines(n_hE);

% Plot all hE values on one graph
for hE_idx = 1:n_hE
    % Solid line for BMR
    plot(strengths, bmr_F(:, hE_idx), 'Color', colors(hE_idx,:), 'LineStyle', '-', ...
        'DisplayName', sprintf('BMR hE=%d', hE_values(hE_idx)));
    % Dashed line for BMC
    plot(strengths, bmc_F(:, hE_idx), 'Color', colors(hE_idx,:), 'LineStyle', '--', ...
        'DisplayName', sprintf('BMC hE=%d', hE_values(hE_idx)));
end

xlabel('Prior covariance');
ylabel('Relative Free Energy');
title('Free Energy Comparison Across hE Values');
legend show;
grid on;