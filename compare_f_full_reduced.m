function compare_f_full_reduced(n)
%==========================================================================
% This function compares the Free Energy F between a Full DCM and multiple
% DCMs with modified connectivity strengths and plots the difference in
% Free Energy between the Full and modified DCMs.

% It does this for Models which were reduced with BMR and Models which were
% individually inverted previously and imported. 
%==========================================================================


spm('defaults', 'eeg')


switch n
    case 1
        % Load multi-subject data for variance calculation
        %Struct = load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/DCMs_multi_subject_BMR_fail.mat'); %BMC failure

        Struct = load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/results/DCMs_multi_subject_final_fine_pruning_bmr_fail.mat'); %BMR failure


        DCMs_multi = Struct.DCMs_multi;
        strengths = Struct.strengths;
        
        [n_subjects, n_strengths] = size(DCMs_multi);
        
        % Calculate ALL subjects for variance
        reduced_F_all = zeros(n_subjects, n_strengths);
        F_diff_all = zeros(n_subjects, n_strengths);
        
        for subj = 1:n_subjects
            % Reference model parameters
            qE = DCMs_multi{subj,1}.Ep;
            qC = DCMs_multi{subj,1}.Cp;
            pE = DCMs_multi{subj,1}.M.pE;
            pC = DCMs_multi{subj,1}.M.pC;
            
            for i = 1:n_strengths
                [~,rC,rE] = spm_find_pC(DCMs_multi{subj,i});
                [reduced_F_all(subj,i),~,~] = spm_log_evidence_reduce(qE,qC,pE,pC,rE,rC);
                F_diff_all(subj,i) = DCMs_multi{subj,i}.F - DCMs_multi{subj,1}.F;
            end
        end
        
        % Calculate GROUP AVERAGES and STANDARD DEVIATIONS
        group_mean_reduced = mean(reduced_F_all, 1);  % Mean across subjects
        group_std_reduced = std(reduced_F_all, 0, 1); % Std across subjects
        group_mean_F = mean(F_diff_all, 1);
        group_std_F = std(F_diff_all, 0, 1);

        ci_reduced = 1.95 * (group_std_reduced ./ sqrt(n_subjects));
        ci_F       = 1.95 * (group_std_F       ./ sqrt(n_subjects));
        
        % Plot group averages with standard deviation
        figure; hold on;
        
        % Shaded confidence intervals
        fill([strengths, fliplr(strengths)], ...
             [group_mean_reduced + ci_reduced, fliplr(group_mean_reduced - ci_reduced)], ...
             'r', 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'DisplayName', 'BMR ± CI');
        fill([strengths, fliplr(strengths)], ...
             [group_mean_F + ci_F, fliplr(group_mean_F - ci_F)], ...
             'b', 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'DisplayName', 'BMC ± CI');
        
        % Smooth dotted mean lines
        plot(strengths, group_mean_reduced, 'r:', 'LineWidth', 1.5, 'DisplayName', 'BMR Group Mean');
        plot(strengths, group_mean_F, 'b:', 'LineWidth', 1.5, 'DisplayName', 'BMC Group Mean');
        
        % Elegant small markers at fitted points (minimal, semi-transparent)
        scatter(strengths, group_mean_reduced, 25, 'r', ...
            'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none');
        scatter(strengths, group_mean_F, 25, 'b', ...
            'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none');
        
        xlabel('Connectivity strength');
        ylabel('Free Energy difference (relative to starting model)');
        title(sprintf('Group Average Free Energy (N=%d subjects)', n_subjects));
        legend('Location', 'best');
        grid on;
        box on;
        set(gca, 'FontSize', 12, 'LineWidth', 1);




    %     % Plot group averages with standard deviation
    %     figure; hold on;
    % 
    %     % Group standard deviation as shaded regions
    %     fill([strengths, fliplr(strengths)], ...
    %          [group_mean_reduced + ci_reduced, fliplr(group_mean_reduced - ci_reduced)], ...
    %          'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'BMR ± SD');
    %     fill([strengths, fliplr(strengths)], ...
    %          [group_mean_F + ci_F, fliplr(group_mean_F - ci_F)], ...
    %          'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'BMC ± SD');
    % 
    %     % Group mean lines
    %     plot(strengths, group_mean_reduced, 'r-', 'LineWidth', 2, 'DisplayName', 'BMR Group Mean');
    %     plot(strengths, group_mean_F, 'b--', 'LineWidth', 2, 'DisplayName', 'BMC Group Mean');
    % 
    %     xlabel('Connectivity strength');
    %     ylabel('Free Energy difference (relative to starting model)');
    %     title(sprintf('Group Average Free Energy (N=%d subjects)', n_subjects));
    %     legend('Location', 'best');
    %     grid on;
    % 
    %     % Print some summary statistics
    %     fprintf('Group BMR range: %.2f to %.2f\n', min(group_mean_reduced), max(group_mean_reduced));
    %     fprintf('Group BMC range: %.2f to %.2f\n', min(group_mean_F), max(group_mean_F));
    % 
    % case 2
    %     % Similar for 2-parameter case...
    %     
end
end