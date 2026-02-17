function probability_thresholder(DCM)
%==========================================================================
 %Identifies DCM connections with high posterior probabilities

% This function examines the posterior probabilities of DCM.B parameters
% and reports connections that have a high probability (>= 0.9) of being non-zero.

%==========================================================================

% 
% for k = 1:length(DCM.Pp.B)
%     significant_connections = find(DCM.Pp.B{k} >= 0.9);
%     [rows, cols] = ind2sub(size(DCM.Pp.B{k}), significant_connections);
%     for i = 1:length(rows)
%         fprintf('Input %d: Connection from region %d to region %d is significant with P >= 0.9\n', k, cols(i), rows(i));
%     end
% end
% 


for k = 1:length(DCM.Pp.B)
    % Find connections with posterior probability >= 0.9
    significant_connections = find(DCM.Pp.B{k} >= 0.9);
    
    % Convert linear indices to subscripts (row and column indices)
    [rows, cols] = ind2sub(size(DCM.Pp.B{k}), significant_connections);
    
    % Loop through significant connections and print information
    for i = 1:length(rows)
        from_region = DCM.Sname{cols(i)};
        to_region = DCM.Sname{rows(i)};
        
        fprintf('Input %d: Connection from %s (region %d) to %s (region %d) is significant with P >= 0.9\n', ...
                k, from_region, cols(i), to_region, rows(i));
    end
end

% Print a message if no significant connections were found
if isempty(significant_connections)
    fprintf('No connections with posterior probability >= 0.9 were found.\n');
end