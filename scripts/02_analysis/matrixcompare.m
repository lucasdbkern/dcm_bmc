function matrixcompare(matFilePath_A, matFilePath_B, matFilePath_C)

% Check if the files exist before loading
if exist(matFilePath_A, 'file') == 2
    loadedData_A = load(matFilePath_A);
    A = loadedData_A.matrix;
else
    error('File not found: %s', matFilePath_A);
end

if exist(matFilePath_B, 'file') == 2
    loadedData_B = load(matFilePath_B);
    B = loadedData_B.matrix;
else
    error('File not found: %s', matFilePath_B);
end

if exist(matFilePath_C, 'file') == 2
    loadedData_C = load(matFilePath_C);
    C = loadedData_C.matrix;
else
    error('File not found: %s', matFilePath_C);
end

% Initialize matrices to store differences
diff_AB = zeros(size(A));
diff_AC = zeros(size(A));
diff_BC = zeros(size(A));

% Calculate the differences
diff_AB = A - B;
diff_AC = A - C;
diff_BC = B - C;

% Find the indices where the differences are non-zero for each pair
[diff_AB_rows, diff_AB_cols] = find(diff_AB ~= 0);
[diff_AC_rows, diff_AC_cols] = find(diff_AC ~= 0);
[diff_BC_rows, diff_BC_cols] = find(diff_BC ~= 0);

% Display the results
fprintf('Differences between A and B:\n');
for i = 1:length(diff_AB_rows)
    fprintf('Row %d, Column %d: A=%.2f, B=%.2f, Difference=%.2f\n', ...
        diff_AB_rows(i), diff_AB_cols(i), A(diff_AB_rows(i), diff_AB_cols(i)), ...
        B(diff_AB_rows(i), diff_AB_cols(i)), diff_AB(diff_AB_rows(i), diff_AB_cols(i)));
end

fprintf('\nDifferences between A and C:\n');
for i = 1:length(diff_AC_rows)
    fprintf('Row %d, Column %d: A=%.2f, C=%.2f, Difference=%.2f\n', ...
        diff_AC_rows(i), diff_AC_cols(i), A(diff_AC_rows(i), diff_AC_cols(i)), ...
        C(diff_AC_rows(i), diff_AC_cols(i)), diff_AC(diff_AC_rows(i), diff_AC_cols(i)));
end

fprintf('\nDifferences between B and C:\n');
for i = 1:length(diff_BC_rows)
    fprintf('Row %d, Column %d: B=%.2f, C=%.2f, Difference=%.2f\n', ...
        diff_BC_rows(i), diff_BC_cols(i), B(diff_BC_rows(i), diff_BC_cols(i)), ...
        C(diff_BC_rows(i), diff_BC_cols(i)), diff_BC(diff_BC_rows(i), diff_BC_cols(i)));
end

end














% function matrixcompare(matFilePath_A, matFilePath_B, matFilePath_C)
% 
% 
% 
% % Check if the files exist before loading
% if exist(matFilePath_A, 'file') == 2
%     loadedData_A = load(matFilePath_A);
%     A = loadedData_A
% else
%     error('File not found: %s', matFilePath_A);
% end
% 
% if exist(matFilePath_B, 'file') == 2
%     loadedData_B = load(matFilePath_B);
%     B = loadedData_B
% else
%     error('File not found: %s', matFilePath_B);
% end
% 
% if exist(matFilePath_C, 'file') == 2
%     loadedData_C = load(matFilePath_C);
%     C = loadedData_C
% else
%     error('File not found: %s', matFilePath_C);
% end
% 
% % Initialize matrices to store differences
% diff_AB = zeros(size(A));
% diff_AC = zeros(size(A));
% diff_BC = zeros(size(A));
% 
% % Calculate the differences
% diff_AB = A - B;
% diff_AC = A - C;
% diff_BC = B - C;
% 
% % Find the indices where the differences are non-zero for each pair
% [diff_AB_rows, diff_AB_cols] = find(diff_AB ~= 0);
% [diff_AC_rows, diff_AC_cols] = find(diff_AC ~= 0);
% [diff_BC_rows, diff_BC_cols] = find(diff_BC ~= 0);
% 
% % Display the results
% fprintf('Differences between A and B:\n');
% for i = 1:length(diff_AB_rows)
%     fprintf('Row %d, Column %d: A=%.2f, B=%.2f, Difference=%.2f\n', ...
%         diff_AB_rows(i), diff_AB_cols(i), A(diff_AB_rows(i), diff_AB_cols(i)), ...
%         B(diff_AB_rows(i), diff_AB_cols(i)), diff_AB(diff_AB_rows(i), diff_AB_cols(i)));
% end
% 
% fprintf('\nDifferences between A and C:\n');
% for i = 1:length(diff_AC_rows)
%     fprintf('Row %d, Column %d: A=%.2f, C=%.2f, Difference=%.2f\n', ...
%         diff_AC_rows(i), diff_AC_cols(i), A(diff_AC_rows(i), diff_AC_cols(i)), ...
%         C(diff_AC_rows(i), diff_AC_cols(i)), diff_AC(diff_AC_rows(i), diff_AC_cols(i)));
% end
% 
% fprintf('\nDifferences between B and C:\n');
% for i = 1:length(diff_BC_rows)
%     fprintf('Row %d, Column %d: B=%.2f, C=%.2f, Difference=%.2f\n', ...
%         diff_BC_rows(i), diff_BC_cols(i), B(diff_BC_rows(i), diff_BC_cols(i)), ...
%         C(diff_BC_rows(i), diff_BC_cols(i)), diff_BC(diff_BC_rows(i), diff_BC_cols(i)));
% end
% 
% 
% 
% 












% 
% % Define the path to the .mat file
% matFilePath1 = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/roving-oddball-dataset/subject_TRA01_1.mat';
% matFilePath2 = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/roving-oddball-dataset/subject_ORA01_1.mat';
% matFilePath3 = '/Users/lucaskern/Desktop/Desktop/UCL/Research_Project/roving-oddball-dataset/subject_FullA01_1.mat';
% 
% % Load the .mat file
% loadedData1 = load(matFilePath1);
% loadedData2 = load(matFilePath2);
% loadedData3 = load(matFilePath3);
% 
% % Access the specific field to get matrix A
% A = loadedData1.DCMi.xY.y{1,1};
% B = loadedData2.DCMi.xY.y{1,1};
% C = loadedData3.DCMi.xY.y{1,1};
% 
% 
% % Initialize matrices to store differences
% diff_AB = zeros(58, 34);
% diff_AC = zeros(58, 34);
% diff_BC = zeros(58, 34);
% 
% % Calculate the differences
% diff_AB = A - B;
% diff_AC = A - C;
% diff_BC = B - C;
% 
% % Find the indices where the differences are non-zero for each pair
% [diff_AB_rows, diff_AB_cols] = find(diff_AB ~= 0);
% [diff_AC_rows, diff_AC_cols] = find(diff_AC ~= 0);
% [diff_BC_rows, diff_BC_cols] = find(diff_BC ~= 0);
% 
% % Display the results
% fprintf('Differences between A and B:\n');
% for i = 1:length(diff_AB_rows)
%     fprintf('Row %d, Column %d: A=%.2f, B=%.2f, Difference=%.2f\n', ...
%         diff_AB_rows(i), diff_AB_cols(i), A(diff_AB_rows(i), diff_AB_cols(i)), ...
%         B(diff_AB_rows(i), diff_AB_cols(i)), diff_AB(diff_AB_rows(i), diff_AB_cols(i)));
% end
% 
% fprintf('\nDifferences between A and C:\n');
% for i = 1:length(diff_AC_rows)
%     fprintf('Row %d, Column %d: A=%.2f, C=%.2f, Difference=%.2f\n', ...
%         diff_AC_rows(i), diff_AC_cols(i), A(diff_AC_rows(i), diff_AC_cols(i)), ...
%         C(diff_AC_rows(i), diff_AC_cols(i)), diff_AC(diff_AC_rows(i), diff_AC_cols(i)));
% end
% 
% fprintf('\nDifferences between B and C:\n');
% for i = 1:length(diff_BC_rows)
%     fprintf('Row %d, Column %d: B=%.2f, C=%.2f, Difference=%.2f\n', ...
%         diff_BC_rows(i), diff_BC_cols(i), B(diff_BC_rows(i), diff_BC_cols(i)), ...
%         C(diff_BC_rows(i), diff_BC_cols(i)), diff_BC(diff_BC_rows(i), diff_BC_cols(i)));
% end
