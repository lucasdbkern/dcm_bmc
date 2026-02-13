function debug_kl_computation()
%==========================================================================
% Simplified debug version without problematic functions
%==========================================================================

% Test with one subject first
subject = 1;
dcm_file = sprintf('subject_folder/subject_%d/derivatives/DCMij.mat', subject);

if ~exist(dcm_file, 'file')
    fprintf('ERROR: File not found: %s\n', dcm_file);
    return;
end

data = load(dcm_file);

% Check if DCMij exists
if ~isfield(data, 'DCMij')
    fprintf('ERROR: DCMij field not found in file\n');
    return;
end

% Extract models
DCMs = {data.DCMij{1,1}, data.DCMij{2,2}, data.DCMij{3,3}};
model_names = {'Full', 'ORA', 'TRA'};

fprintf('=== DEBUGGING SUBJECT %d ===\n', subject);

% Check each model
for i = 1:3
    DCM = DCMs{i};
    fprintf('\n--- %s Model ---\n', model_names{i});
    
    % Check basic properties
    if isfield(DCM, 'H') && isfield(DCM, 'R')
        fprintf('Has H and R fields: YES\n');
        fprintf('Number of conditions: %d\n', length(DCM.H));
        
        for cond = 1:length(DCM.H)
            pred = DCM.H{cond};
            res = DCM.R{cond};
            
            fprintf('Condition %d:\n', cond);
            fprintf('  Prediction size: [%d x %d]\n', size(pred));
            fprintf('  Residual size: [%d x %d]\n', size(res));
            fprintf('  Prediction range: [%.3f, %.3f]\n', min(pred(:)), max(pred(:)));
            fprintf('  Residual range: [%.3f, %.3f]\n', min(res(:)), max(res(:)));
            
            if any(isnan(pred(:)))
                fprintf('  Any NaN in pred: YES\n');
            else
                fprintf('  Any NaN in pred: NO\n');
            end
            
            if any(isnan(res(:)))
                fprintf('  Any NaN in res: YES\n');
            else
                fprintf('  Any NaN in res: NO\n');
            end
        end
    else
        fprintf('Missing H or R fields!\n');
        fprintf('Available fields: %s\n', strjoin(fieldnames(DCM), ', '));
    end
end

% Test simple KL computation
fprintf('\n=== TESTING SIMPLE KL ESTIMATION ===\n');
for i = 1:3
    for j = 1:3
        if i ~= j
            try
                % Simple free energy difference
                F_diff = abs(DCMs{j}.F - DCMs{i}.F);
                fprintf('F_diff[%s||%s] = %.4f\n', model_names{j}, model_names{i}, F_diff);
            catch ME
                fprintf('ERROR: %s\n', ME.message);
            end
        end
    end
end
end