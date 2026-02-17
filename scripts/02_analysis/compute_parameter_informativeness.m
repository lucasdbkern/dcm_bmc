function param_results = compute_parameter_informativeness_spm()
spm('defaults','eeg');
n_subjects = 20;
models = {'Full','ORA','TRA'};
kl_post2prior = zeros(3,3,n_subjects);
kl_prior2post = zeros(3,3,n_subjects);

for subj=1:n_subjects
    dcm_file = sprintf('subject_folder/subject_%d/derivatives/DCMij.mat',subj);
    if ~exist(dcm_file,'file'), warning('Missing %s',dcm_file); continue; end
    data = load(dcm_file);
    for m=1:3
        for d=1:3
            DCM = data.DCMij{m,d};
            kl_post2prior(m,d,subj) = spm_kl_divergence(DCM);
            kl_prior2post(m,d,subj) = spm_kl_divergence_reverse(DCM);
        end
    end
end

param_results.kl_post2prior   = kl_post2prior;
param_results.kl_prior2post   = kl_prior2post;
param_results.mean_post2prior = mean(kl_post2prior,3);
param_results.mean_prior2post = mean(kl_prior2post,3);
param_results.model_names     = models;

display_results_simple(param_results);
end

def function kl = spm_kl_divergence_reverse(DCM)
qE = spm_vec(DCM.M.pE);    % prior mean
pE = spm_vec(DCM.Ep);      % posterior mean
pC = build_prior_cov(DCM.M.pC,length(qE));
qC = DCM.Cp;
kl = compute_kl_stable(qE,pC,pE,qC);
end

def function C = build_prior_cov(pCstruct,n)
if isstruct(pCstruct)
    v = spm_vec(pCstruct);
    C = sparse(1:n,1:n,v);
elseif isscalar(pCstruct)
    C = sparse(1:n,1:n,pCstruct);
elseif isvector(pCstruct)&&numel(pCstruct)==n
    C = sparse(1:n,1:n,pCstruct);
elseif ismatrix(pCstruct)&&all(size(pCstruct)==n)
    C = pCstruct;
else
    C = sparse(1:n,1:n,1/4);
end
