function compare_posteriors()
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
% load peb+bmr and bmc structures
%--------------------------------------------------------------------------

% load peb+bmr structure 
%-----------------------
caseType  = 'ORA';
BMR_path = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results';
peb_bmr_file = fullfile(BMR_path, sprintf('peb_bmr_results_%s.mat', caseType));
peb_data = load(peb_bmr_file, 'BMR', 'BMA');

% load bmc structure
%-------------------
BMC_data = cell(20,1);  
for subj = 1:20            
    % Load subject-specific DCM
    results = load(sprintf('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/subject_%d/derivatives/DCMij.mat', subj));

    if strcmp(caseType, 'ORA')
        BMC_data{subj} = results.DCMij{2,2};
    end

    if strcmp(caseType, 'TRA')
        BMC_data{subj} = results.DCMij{3,3};
    end 
end 


%--------------------------------------------------------------------------
% Reference indices/names from full model (anchor for ALL extractions)
%--------------------------------------------------------------------------
ref_dcm  = load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/subject_1/derivatives/DCMij.mat');
DCM_full = ref_dcm.DCMij{1,1};

% vectorised field indices and names (all B)
qB_full    = spm_fieldindices(DCM_full.M.pE,'B');
names_full = spm_fieldindices(DCM_full.M.pE,qB_full);

% find active entries (B{1,1} == 1) — if you want to restrict to ON entries
mask_active = spm_vec(DCM_full.B{1,1}) == 1;

% keep only these parameters (comment out next two lines if you want ALL B)
qB_full    = qB_full(mask_active);
names_full = names_full(mask_active);

% Number of parameters in full model
N = numel(qB_full);


%--------------------------------------------------------------------------
% load peb+bmr and bmc posteriors
%--------------------------------------------------------------------------


%load posteriors for BMR
%-----------------------
Ep_bmr   = peb_data.BMA.Ep;        % BMR posterior means 
names_bmr= peb_data.BMA.Pnames;    % parameter names, same order as Ep
Cp_bmr   = peb_data.BMA.Cp;        % posterior covariance (group level)

% Calculate 95% confidence interval for BMR (using posterior SD)
%--------------------------
sd_bmr   = sqrt(diag(Cp_bmr));     % standard deviation
ci95_bmr = 1.96 * sd_bmr;          % 95% CI half-widths (z = 1.96)


% load posteriors for BMC 
%------------------------
S = numel(BMC_data);
MU  = cell(S,1); SD = cell(S,1); CI = cell(S,1);
for s = 1:S
    DCM   = BMC_data{s};
    theta = spm_vec(DCM.Ep);
    Cp    = DCM.Cp;

    % *** use the SAME qB_full for every subject ***
    MU{s} = theta(qB_full);
    SD{s} = sqrt(diag(Cp(qB_full,qB_full)));
    CI{s} = spm_invNcdf(0.95) * SD{s};    % if you still want it
end

% Calculate 95% confidence interval for BMC 
%--------------------------
MU_mat   = cell2mat(MU);                 % [N x S] numeric
mu_bmc   = mean(MU_mat, 2);              % mean across subjects (N×1)
sem_bmc  = std(MU_mat, 0, 2) / sqrt(S);  % SEM across subjects

% t-distribution for 95% CI
df        = S - 1;                       
t_crit    = tinv(0.975, df);             
ci95_bmc  = t_crit * sem_bmc;            % 95% CI half-widths


%--------------------------------------------------------------------------
% Match parameters between BMR and BMC
%--------------------------------------------------------------------------

% Initialize BMR arrays with zeros (aligned to names_full/qB_full)
Ep_bmr_matched   = zeros(N, 1);
ci95_bmr_matched = zeros(N, 1);

% Fill in BMR values where they exist; if absent -> stays 0 (pruned)
for i = 1:N
    idx = find(strcmp(names_bmr, names_full{i}), 1);
    if ~isempty(idx)
        Ep_bmr_matched(i)   = Ep_bmr(idx);
        ci95_bmr_matched(i) = ci95_bmr(idx);
    end
end

% Use full model names (already filtered by mask if enabled)
names_matched = names_full;


%--------------------------------------------------------------------------
% plot
%--------------------------------------------------------------------------

% ---- normalize vectors to common length and shape ----
L = min([ numel(names_matched), numel(mu_bmc), numel(ci95_bmc), ...
          numel(Ep_bmr_matched), numel(ci95_bmr_matched) ]);

names = names_matched(1:L);
y1    = mu_bmc(1:L);
c1    = ci95_bmc(1:L);
y2    = Ep_bmr_matched(1:L);
c2    = ci95_bmr_matched(1:L);

% column vectors
y1 = y1(:); c1 = c1(:); y2 = y2(:); c2 = c2(:);
x  = (1:L)';        % column vector to match
dx = 0.18;



figure('Color','w','Name','BMC (blue) vs BMR (red)'); hold on
yline(0,'-','Color',[0.6 0.6 0.6],'LineWidth',1.2);

% hex -> RGB in [0,1]
c_bmc = [102 198 213] / 255;   % 66c6d5ff
c_bmr = [153 211 149] / 255;   % 99d395ff

% CIs
for i = 1:L
    plot([x(i)-dx x(i)-dx],[y1(i)-c1(i) y1(i)+c1(i)], 'Color', c_bmc, 'LineWidth',2);
    plot([x(i)+dx x(i)+dx],[y2(i)-c2(i) y2(i)+c2(i)], 'Color', c_bmr, 'LineWidth',2);
end

% means
scatter(x-dx, y1, 30, 'MarkerEdgeColor', c_bmc, 'MarkerFaceColor', c_bmc, 'MarkerFaceAlpha',0.65);
scatter(x+dx, y2, 30, 'MarkerEdgeColor', c_bmr, 'MarkerFaceColor', c_bmr, 'MarkerFaceAlpha',0.65);


hold off
set(gca,'XTick',x,'XTickLabel',names,'TickLabelInterpreter','none'); xtickangle(45);
xlabel('Parameter'); ylabel('Posterior mean'); xlim([0.5, L+0.5]);

vals = [y1-c1; y1+c1; y2-c2; y2+c2]; vals = vals(isfinite(vals));
if isempty(vals), ymin=-1; ymax=1; else, ymin=min(vals); ymax=max(vals); if ~(ymax>ymin), ymin=ymin-1; ymax=ymax+1; end, end
pad = 0.05*(ymax-ymin); ylim([ymin-pad, ymax+pad]); box on; grid on

