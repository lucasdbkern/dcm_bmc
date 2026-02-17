function plot_free_energy_vs_pruning_strength(subject_nums, model1_idx, model2_idx, base_path)
%=========================================================================
% Visualise posterior means of pruned parameters
% across DCM model comparisons.
%
%   plot_pruned_scatter(subject_nums, model1_idx, model2_idx)
%   plot_pruned_scatter(subject_nums, model1_idx, model2_idx, base_path)
%
% Inputs
%   subject_nums : Vector of subject IDs (e.g. 1:20 or [1 5 10])
%   model1_idx   : [i j] index of first model in the DCM cell array
%                  (usually the full model, e.g. [2 2] → M2 fitted to M2)
%   model2_idx   : [i j] index of second model (usually reduced/pruned),
%                  e.g. [2 3] → M2 fitted to M3
%   base_path    : Path to subject folders.  Default points to local repo.
%
% The function extracts the Ep fields from the corresponding DCM objects,
% selects only those parameters that are pruned in *model2 (or 3)*, and plots a
% scatter with regression line of model-1 versus model-2 posteriors.
%=========================================================================

%--------------------------- defaults & checks ---------------------------%
if nargin < 4 || isempty(base_path)
    base_path = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder';
end

validateattributes(subject_nums, {'numeric'}, {'vector','integer','positive'}, '', 'subject_nums');
validateattributes(model1_idx,   {'numeric'}, {'vector','numel',2,'integer','positive'});
validateattributes(model2_idx,   {'numeric'}, {'vector','numel',2,'integer','positive'});

%---------------------------- housekeeping --------------------------------%
all_pruned1  = [];
all_pruned2  = [];
loaded_subjs = 0;

%--------------------------- subject loop ---------------------------------%
for subj = subject_nums(:)'
    file_path = fullfile(base_path, sprintf('subject_%d', subj), ...
                         'derivatives', 'DCMij.mat');
    if ~exist(file_path, 'file')
        warning('plot_pruned_scatter:FileMissing', ...
                'File not found for subject %d.  Skipping.', subj);
        continue;
    end

    S = load(file_path, 'DCMij');
    DCMij = S.DCMij;

    try
        DCM1 = DCMij{model1_idx(1), model1_idx(2)};
        DCM2 = DCMij{model2_idx(1), model2_idx(2)};
    catch
        warning('plot_pruned_scatter:IndexError', ...
                'Indices out of range for subject %d.  Skipping.', subj);
        continue;
    end

    p1 = spm_vec(DCM1.Ep);
    p2 = spm_vec(DCM2.Ep);

    % figure out which parameters were pruned in the *target* (model2)
    pruned_indices = get_pruned_indices(DCM1.Ep, model2_idx(2));

    if isempty(pruned_indices)
        warning('plot_pruned_scatter:NoPrunes', ...
                'No pruned parameters for subject %d under target model %d.', ...
                subj, model2_idx(2));
        continue;
    end

    pruned_indices = unique(pruned_indices);

    all_pruned1 = [all_pruned1; p1(pruned_indices)]; %#ok<AGROW>
    all_pruned2 = [all_pruned2; p2(pruned_indices)]; %#ok<AGROW>

    loaded_subjs = loaded_subjs + 1;
end

if isempty(all_pruned1)
    error('plot_pruned_scatter:NoData', ...
          'No data harvested.  Verify paths and model indices.');
end

%--------------------------- plotting -------------------------------------%
figure('Color','w'); hold on;

scatter(all_pruned1, all_pruned2, 60, 'filled', 'MarkerFaceAlpha', 0.65);

% identity line
lims = get_lims([all_pruned1; all_pruned2]);
plot(lims, lims, '--', 'LineWidth', 1.5);

% regression
b = polyfit(all_pruned1, all_pruned2, 1);
plot(lims, polyval(b, lims), '-', 'LineWidth', 2);

axis equal; axis([lims lims]); grid on;

xlabel(sprintf('M%d → M%d posterior', model1_idx(1), model1_idx(2)));
ylabel(sprintf('M%d → M%d posterior', model2_idx(1), model2_idx(2)));

title(sprintf('Pruned Parameters (N = %d subj, %d params each)', ...
      loaded_subjs, numel(all_pruned1)/loaded_subjs));

legend({'Posteriors', 'Identity', sprintf('Regress: y=%.2fx+%.2f', b)}, ...
       'Location','best');

%--------------------------- stats print ----------------------------------%
r   = corr(all_pruned1, all_pruned2, 'type','Pearson');
Rsq = r^2;

fprintf('Slope %.4f, Intercept %.4f, R² %.4f (N_subj=%d, N_param=%d)\n', ...
        b(1), b(2), Rsq, loaded_subjs, numel(all_pruned1));
end

%=========================================================================
function pruned_indices = get_pruned_indices(Ep, target_model)
% Return linear indices of parameters pruned in TARGET_MODEL.
% Mapping follows manuscript specification.

switch target_model
    case 2  % Model 2 (ORA): rSTG ⇄ rIFG only
        conns = {'B{1}(4,5)', 'B{1}(5,4)'};
    case 3  % Model 3 (TRA): rSTG⇄rIFG + hemispheric
        conns = {'B{1}(4,5)', 'B{1}(5,4)', ...
                 'A{1}(4,2)', 'A{1}(3,1)', ...
                 'A{2}(2,4)', 'A{2}(1,3)'};
    otherwise
        conns = {}; % Full model: nothing pruned
end

pruned_indices = [];
for c = conns
    try
        pruned_indices = [pruned_indices; spm_fieldindices(Ep, c{1})]; %#ok<AGROW>
    catch
        % If a connection is absent, silently ignore—it may be pruned at spec level
    end
end
end

%=========================================================================
function lims = get_lims(data)
% symmetric limits with 5 % margin
rng = max(data) - min(data);
margin = 0.05 * rng;
lims = [min(data)-margin, max(data)+margin];
end
%=========================================================================


