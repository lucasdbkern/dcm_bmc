spm('defaults','eeg');

n_subjects = 20;
models     = {'Full','ORA','TRA'};
parameter_kl = nan(3,3,n_subjects);                    % [fitted_model , data_source , subject]

eps_jitter = 1e-12;                                    % numerical floor

for s = 1:n_subjects
    f = sprintf('subject_folder/subject_%d/derivatives/DCMij.mat',s);
    if ~exist(f,'file'); warning('Missing %s',f); continue; end
    load(f,'DCMij');                                   % 3×3 cell array

    for i = 1:3                                        % prior model i
        mu_p  = spm_vec(DCMij{i,i}.M.pE);
        var_p = max(spm_vec(DCMij{i,i}.M.pC),eps_jitter);
        inv_p = 1./var_p;                              % diagonal Σ_p⁻¹
        logdet_p = sum(log(var_p));
        k = numel(mu_p);

        for j = 1:3                                    % posterior from model i fit to data j
            mu_q = spm_vec(DCMij{i,j}.Ep);
            Cp   = DCMij{i,j}.Cp;

            if isvector(Cp)                            % diagonal posterior
                var_q_diag = max(double(Cp(:)),eps_jitter);
                trace_term = sum(inv_p .* var_q_diag);
                logdet_q   = sum(log(var_q_diag));
            else                                       % full posterior
                Sigma_q    = full(double(Cp));
                var_q_diag = diag(Sigma_q);
                trace_term = sum(inv_p .* var_q_diag);
                logdet_q   = safe_logdet(Sigma_q);
            end

            diff       = mu_p - mu_q;
            quad_term  = sum(inv_p .* (diff.^2));      % (μ_p-μ_q)' Σ_p⁻¹ (μ_p-μ_q)
            parameter_kl(i,j,s) = 0.5*(trace_term + quad_term - k + logdet_p - logdet_q);
        end
    end
end

rep_results.mean_kl   = nanmean(parameter_kl,3);
rep_results.model_names = models;

figure('Position',[100 100 1200 500]);
subplot(1,2,1);
imagesc(rep_results.mean_kl);
violet = [0.384 0.310 0.647]; white = [1 1 1];
steps  = linspace(0,1,256)';
colormap([white.*(1-steps)+violet.*steps]); colorbar;
title('Representational Capacity','FontSize',12,'FontWeight','bold');
xlabel('Model Architecture (fitted)','FontSize',11);
ylabel('True Data Source','FontSize',11);
set(gca,'XTick',1:3,'XTickLabel',models,'YTick',1:3,'YTickLabel',models);
axis square;
for i = 1:3
    for j = 1:3
        if i~=j
            text(j,i,sprintf('%.2f',rep_results.mean_kl(i,j)),...
                 'HorizontalAlignment','center','VerticalAlignment','middle',...
                 'FontSize',10,'FontWeight','bold','Color','white');
        end
    end
end

% ───────── helper ───────────────────────────────────────────────────────
function y = safe_logdet(S)
try
    u = chol(S);
    y = 2*sum(log(diag(u)));
catch
    s = svd(S);
    y = sum(log(max(s,realmin)));
end
end