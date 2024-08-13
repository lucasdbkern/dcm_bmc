function GBF(file_path)
%==========================================================================
%THis Function calculates the log Group Bayes Factor 
 
%==========================================================================

    % Load the Free Energy matrix
    load(file_path, 'F');
    
    [num_subjects, num_models] = size(F);
    
    % Choose the first model as the reference model
    reference_model = 1;
    
    % Calculate log Bayes factors
    % Note: Since F is already negative log scale, we subtract reference from others
    log_BF = F(:, reference_model) - F;
    
    % Calculate log Group Bayes Factor
    log_GBF = sum(log_BF, 1);
    
    % Report results
    disp('Log Group Bayes Factors (relative to reference model):');
    for i = 1:num_models
        if i ~= reference_model
            fprintf('Model %d vs Model %d: %.2f\n', i, reference_model, log_GBF(i));
        end
    end
    
    % Interpret results
    disp('Interpretation:');
    for i = 1:num_models
        if i ~= reference_model
            if log_GBF(i) > 3
                fprintf('Very strong evidence for Model %d over Model %d\n', reference_model, i);
            elseif log_GBF(i) > 1
                fprintf('Strong evidence for Model %d over Model %d\n', reference_model, i);
            elseif log_GBF(i) > 0
                fprintf('Positive evidence for Model %d over Model %d\n', reference_model, i);
            elseif log_GBF(i) > -1
                fprintf('Weak evidence for Model %d over Model %d\n', i, reference_model);
            elseif log_GBF(i) > -3
                fprintf('Strong evidence for Model %d over Model %d\n', i, reference_model);
            else
                fprintf('Very strong evidence for Model %d over Model %d\n', i, reference_model);
            end
        end
    end
    
    % Visualize the results
    figure;
    bar(log_GBF);
    title('Log Group Bayes Factors');
    xlabel('Model');
    ylabel('Log Group Bayes Factor');
    xticklabels(arrayfun(@(x) sprintf('Model %d', x), 1:num_models, 'UniformOutput', false));
    xtickangle(45);
    grid on;
end