function compare_free_energies_across_hE()
% Plot accuracy (diag / total) for BMC and PEB+BMR in a single figure.

categories    = {'bmc_B','pebbmr_B'};
base_filename = 'averagePost';

data = struct();
for c = 1:numel(categories)
    cat = categories{c};
    for hE = 2:6
        fname = sprintf('%s_%s_hE%d.mat', base_filename, cat, hE); % expects underscore
        if exist(fname,'file')~=2
            error('File %s not found.', fname);
        end
        S = load(fname);
        if c==1
            data.bmc_B(:,:,hE-1)    = S.averagePost; % 3×3 matrix
        else
            data.pebbmr_B(:,:,hE-1) = S.Pp;          % 3×3 matrix
        end
    end
end

hEvals  = 2:6;
acc_bmc = accuracy_percent(data.bmc_B);
acc_peb = accuracy_percent(data.pebbmr_B);

figure;
plot(hEvals, acc_bmc, '-o', 'LineWidth', 1.5); hold on;
plot(hEvals, acc_peb, '-s', 'LineWidth', 1.5);
xlabel('hE'); ylabel('accuracy (%)');
legend({'BMC','PEB+BMR'}, 'Location', 'best');
ylim([0 100]); grid on;
title('BMC vs PEB+BMR Accuracy');
end

% ──────────────────────────────────────────────────────────────────────────
function acc = accuracy_percent(M)
N = size(M,3); acc = zeros(1,N);
for k = 1:N
    A         = M(:,:,k);
    diag_sum  = trace(A);
    total_sum = sum(A(:));
    acc(k)    = (diag_sum / total_sum) * 100; % 0–100
end
end
