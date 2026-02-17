function debug_parameter_kl()
% Updated debug with better prior covariance handling

dcm_file = 'subject_folder/subject_1/derivatives/DCMij.mat';
data = load(dcm_file);
DCM = data.DCMij{1,1};

fprintf('=== DEBUGGING PARAMETER KL ===\n');
fprintf('DCM.F = %.2f\n', DCM.F);
fprintf('abs(DCM.F)/10 = %.2f\n', abs(DCM.F)/10);
fprintf('Fallback result: %.2f\n', min(10, abs(DCM.F)/10));

% Check dimensions
post_params = spm_vec(DCM.Ep);
prior_params = spm_vec(DCM.M.pE);

fprintf('\nParameter vectors:\n');
fprintf('  Posterior size: %d\n', length(post_params));
fprintf('  Prior size: %d\n', length(prior_params));

% Fix the ternary operator
if length(post_params) == length(prior_params)
    fprintf('  Size match: YES\n');
else
    fprintf('  Size match: NO\n');
end

% Check covariances
fprintf('\nCovariance matrices:\n');
fprintf('  Posterior cov: [%d x %d]\n', size(DCM.Cp));
fprintf('  Prior cov: [%d x %d]\n', size(DCM.M.pC));

% Check prior covariance type
fprintf('  Prior cov class: %s\n', class(DCM.M.pC));
if issparse(DCM.M.pC)
    fprintf('  Prior cov is sparse: YES\n');
else
    fprintf('  Prior cov is sparse: NO\n');
end

% Try to get proper prior covariance
try
    if numel(DCM.M.pC) == 1
        % Scalar prior covariance - expand to diagonal
        fprintf('  Prior cov is scalar: %.6f\n', DCM.M.pC);
        pC_full = DCM.M.pC * speye(length(prior_params));
        fprintf('  Expanded to diagonal: [%d x %d]\n', size(pC_full));
    else
        pC_full = DCM.M.pC;
    end
    
    % Check condition number of expanded prior
    cond_prior = cond(full(pC_full));
    fprintf('  Prior cov condition number: %.2e\n', cond_prior);
    
catch ME
    fprintf('  Error processing prior cov: %s\n', ME.message);
end

% Check parameter differences
param_diff = full(post_params - prior_params);
fprintf('\nParameter changes:\n');
fprintf('  Mean abs change: %.6f\n', mean(abs(param_diff)));
fprintf('  Max abs change: %.6f\n', max(abs(param_diff)));
fprintf('  Std of changes: %.6f\n', std(param_diff));

% Check posterior condition number
cond_post = cond(full(DCM.Cp));
fprintf('  Posterior cov condition: %.2e\n', cond_post);

fprintf('\nDiagnosis:\n');
if abs(DCM.F) > 100
    fprintf('  ❌ Free energy too high (%.1f) -> triggers fallback\n', abs(DCM.F));
end
if size(DCM.M.pC, 1) ~= length(prior_params)
    fprintf('  ❌ Prior covariance dimension mismatch\n');
end
if cond_post > 1e12
    fprintf('  ❌ Posterior covariance is singular\n');
end
end