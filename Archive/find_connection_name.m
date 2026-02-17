function find_connection_name()


results = load('/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/github/subject_folder/subject');
DCM_adj = results.DCM{1,1};


ix = spm_fieldindices(DCM_adj.M.pC, 'A(4,5)');
disp(['Index for A(4,5): ', num2str(ix)]);