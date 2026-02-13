function plot_pruned_triplet(subject_nums, base_path)
%==========================================================================
% PLOT_PRUNED_TRIPLET  Plot the 3 key pruning comparisons as subplots:
%   - M2→M2 vs M2→M1
%   - M3→M3 vs M3→M1
%   - M3→M3 vs M3→M2
%
% Inputs:
%   subject_nums : vector of subject IDs (e.g. 1:20)
%   base_path    : optional path to subject folders
%==========================================================================

if nargin < 2 || isempty(base_path)
    base_path = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder';
end

triplets = {
    [2 2], [2 1];  % ORA vs full
    [3 3], [3 1];  % TRA vs full
    [3 3], [3 2];  % TRA vs ORA
};

labels = {
    'ORA fit vs full fit';
    'TRA fit vs full fit';
    'TRA fit vs ORA fit'
};

figure('Color','w'); 
for k = 1:3
    subplot(1,3,k);
    model1_idx = triplets{k,1};
    model2_idx = triplets{k,2};
    [x, y, N_subj] = extract_pruned_posteriors(subject_nums, model1_idx, model2_idx, base_path);

    if isempty(x) || isempty(y)
        text(0.5, 0.5, 'No Data', 'HorizontalAlignment','center');
        axis off; continue
    end

    scatter(x, y, 30, 'filled', 'MarkerFaceAlpha', 0.6); hold on;
    lims = get_lims([x; y]);
    plot(lims, lims, '--', 'LineWidth', 1.2);
    b = polyfit(x, y, 1);
    r = corr(x, y);
    plot(lims, polyval(b, lims), '-', 'LineWidth', 1.5);
    text(0.05, 0.9, sprintf('R² = %.2f', r^2), ...
         'Units','normalized','FontSize',8);

    axis equal; axis([lims lims]); grid on;
    title(labels{k}, 'FontSize', 10);
    xlabel(sprintf('M%d→M%d', model1_idx(1), model1_idx(2)));
    ylabel(sprintf('M%d→M%d (pruned)', model2_idx(1), model2_idx(2)));
end
sgtitle('Pruned Parameter Posterior Comparisons');
end

%==========================================================================
function [p1_vals, p2_vals, n_subj] = extract_pruned_posteriors(subject_nums, model1_idx, model2_idx, base_path)
p1_vals = [];
p2_vals = [];
n_subj = 0;

for subj = subject_nums(:)'
    file_path = fullfile(base_path, sprintf('subject_%d', subj), 'derivatives', 'DCMij.mat');
    if ~exist(file_path, 'file'), continue; end
    try
        S = load(file_path, 'DCMij');
        DCM1 = S.DCMij{model1_idx(1), model1_idx(2)};
        DCM2 = S.DCMij{model2_idx(1), model2_idx(2)};
    catch
        continue;
    end
    p1 = spm_vec(DCM1.Ep);
    p2 = spm_vec(DCM2.Ep);
    pruned_idx = get_pruned_indices(DCM1.Ep, model2_idx(1));
    if isempty(pruned_idx), continue; end
    pruned_idx = unique(pruned_idx);
    p1_vals = [p1_vals; p1(pruned_idx)]; %#ok<AGROW>
    p2_vals = [p2_vals; p2(pruned_idx)]; %#ok<AGROW>
    n_subj = n_subj + 1;
end
end

%==========================================================================
function pruned_indices = get_pruned_indices(Ep, model_id)
switch model_id
    case 2
        conns = {'B{1}(4,5)', 'B{1}(5,4)'};
    case 3
        conns = {'B{1}(4,5)', 'B{1}(5,4)', ...
                 'A{1}(4,2)', 'A{1}(3,1)', ...
                 'A{2}(2,4)', 'A{2}(1,3)'};
    otherwise
        conns = {};
end
pruned_indices = [];
for c = conns
    try
        pruned_indices = [pruned_indices; spm_fieldindices(Ep, c{1})]; %#ok<AGROW>
    catch
    end
end
end

%==========================================================================
function lims = get_lims(data)
if isempty(data)
    lims = [-1 1];
    return
end
dmin = min(data);
dmax = max(data);
if dmin == dmax
    lims = [dmin - 0.1, dmax + 0.1];
else
    margin = 0.05 * (dmax - dmin);
    lims = [dmin - margin, dmax + margin];
end
end