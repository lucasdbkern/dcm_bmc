function debug_kl_computation()
%==========================================================================
% Debug why KL is returning zeros when parameters clearly moved
%==========================================================================

fprintf('\n=== DEBUGGING KL COMPUTATION ===\n\n');

% Load example DCM
dcm_file = 'subject_folder/subject_1/derivatives/DCMij.mat';
data = load(dcm_file);
DCM = data.DCMij{1,1};

% Extract parameters
qE = full(spm_vec(DCM.Ep));
pE = full(spm_vec(DCM.M.pE));
param_diff = qE - pE;

fprintf('Basic checks:\n');
fprintf('  Parameters that moved: %d/%d\n', sum(abs(param_diff) > 0.001), length(qE));
fprintf('  Max parameter change: %.4f\n', max(abs(param_diff)));

% Test each KL computation method
fprintf('\nTesting different KL methods:\n');

% Method 1: Simple squared difference
kl1 = 0.5 * sum(param_diff.^2);
fprintf('1. Simple squared difference: %.6f\n', kl1);

% Method 2: Extract prior variances properly
if isstruct(DCM.M.pC)
    pC_vec = full(spm_vec(DCM.M.pC));
    fprintf('   Prior variance vector length: %d\n', length(pC_vec));
    fprintf('   Prior variance range: [%.6f, %.6f]\n', min(pC_vec), max(pC_vec));
    
    % Check for zeros or very small values
    n_zeros = sum(pC_vec == 0);
    n_small = sum(pC_vec < 1e-10 & pC_vec > 0);
    fprintf('   Zero variances: %d, Very small (<1e-10): %d\n', n_zeros, n_small);
    
    % Replace problematic values
    pC_vec_safe = pC_vec;
    pC_vec_safe(pC_vec_safe < 1e-10) = 0.25;  % SPM default
    
    kl2 = 0.5 * sum(param_diff.^2 ./ pC_vec_safe);
    fprintf('2. With prior variance weighting: %.6f\n', kl2);
end

% Method 3: Diagonal KL with posterior covariance
qC_diag = full(diag(DCM.Cp));  % Convert to full
fprintf('\n3. Including posterior uncertainty:\n');
fprintf('   Posterior variance range: [%.2e, %.2e]\n', min(qC_diag), max(qC_diag));

% Safe computation avoiding log(0)
qC_safe = max(qC_diag, 1e-16);
pC_safe = max(pC_vec_safe, 1e-16);

kl3_terms = param_diff.^2 ./ pC_safe + qC_safe ./ pC_safe - 1 + log(pC_safe ./ qC_safe);
kl3 = 0.5 * sum(kl3_terms);
fprintf('   Full diagonal KL: %.6f\n', kl3);

% Check for numerical issues
fprintf('\n4. Numerical diagnostics:\n');
fprintf('   Any NaN in KL terms: %s\n', any(isnan(kl3_terms)));
fprintf('   Any Inf in KL terms: %s\n', any(isinf(kl3_terms)));
fprintf('   Negative KL terms: %d\n', sum(kl3_terms < 0));

% Method 4: Using only parameters that moved
moved_idx = abs(param_diff) > 0.01;
if any(moved_idx)
    kl4 = 0.5 * sum(param_diff(moved_idx).^2 ./ pC_safe(moved_idx));
    fprintf('\n5. KL for moved parameters only (%d params): %.6f\n', sum(moved_idx), kl4);
end

% Check what the main function would return
fprintf('\n6. Checking main spm_kl_divergence logic:\n');

% Try spm_log_evidence_reduce if available
try
    pC_mat = sparse(1:length(pC_vec), 1:length(pC_vec), pC_vec_safe);
    qC = DCM.Cp;
    
    % Check dimensions
    if size(qC,1) == length(qE) && size(pC_mat,1) == length(pE)
        [L, ~, ~] = spm_log_evidence_reduce(qE, qC, pE, pC_mat, pE, pC_mat);
        fprintf('   spm_log_evidence_reduce result: %.6f\n', L);
        
        if L > 1000 || isinf(L) || isnan(L)
            fprintf('   WARNING: Unreasonable value from spm_log_evidence_reduce!\n');
        end
    end
catch ME
    fprintf('   spm_log_evidence_reduce failed: %s\n', ME.message);
end

% Visual check
figure('Name', 'KL Debug');
subplot(2,2,1);
histogram(param_diff, 50);
title('Parameter Changes');
xlabel('qE - pE');

subplot(2,2,2);
histogram(log10(pC_vec_safe + eps), 50);
title('Log10(Prior Variances)');
xlabel('log10(variance)');

subplot(2,2,3);
histogram(log10(qC_safe + eps), 50);
title('Log10(Posterior Variances)');
xlabel('log10(variance)');

subplot(2,2,4);
scatter(abs(param_diff), kl3_terms, '.');
xlabel('|Parameter Change|');
ylabel('KL Contribution');
title('Per-parameter KL contributions');

fprintf('\n=== CONCLUSION ===\n');
if kl1 > 0 && kl2 > 0
    fprintf('KL should NOT be zero! Something in the main computation is wrong.\n');
    fprintf('Expected KL range: %.4f to %.4f\n', kl1, kl2);
else
    fprintf('Parameters moved but KL=0 suggests numerical issues.\n');
end

end