function bmc4(file_paths)
% BMC 
% Ensure to wrap file paths in brackets {file, file2, file3} for proper functionality.

success = true;
errmsg = '';

spm('defaults', 'eeg')

% Number of files/models
n = length(file_paths);

DCMs ={};
for i = 1:n
    loaded_data = load(file_paths{i});
    DCMs{i} =loaded_data.DCMi;
    DCMs{i}.M.Nmax =64;
    
end

DCMij = cell(n, n);
for i =1:n
    for j=1:n
        DCMij{i,j} = DCMs{i};
        DCMij{i,j}.xY.y = DCMs{j}.xY.y;
        DCMij{i,j}.name = spm_file(DCMij{i,j}.name,'prefix', 'bmc_');
        DCMij{i,j} = spm_dcm_erp(DCMij{i,j});
    end
end


filename ='DCMij.mat';

save(filename, 'DCMij', '-v7.3');

%save('DCMij.mat', 'DCMij', );


