spm('defaults','eeg');

n_subjects = 20;
models     = {'Full','ORA','TRA'};

true_all = cell(3,3);
rec_all  = cell(3,3);
err_all  = cell(3,3);

for s = 1:n_subjects
    f = sprintf('subject_folder/subject_%d/derivatives/DCMij.mat',s);
    if ~exist(f,'file'); warning('Missing %s',f); continue; end
    load(f,'DCMij');                                   % 3×3 cell array

    for i = 1:3
        for j = 1:3
            p_true = spm_vec(DCMij{j,j}.Ep);
            p_rec  = spm_vec(DCMij{i,j}.Ep);
            p_sd   = sqrt(abs(diag(DCMij{i,j}.Cp))) * 1.96;

            true_all{i,j} = [true_all{i,j}; p_true];
            rec_all{i,j}  = [rec_all{i,j};  p_rec ];
            err_all{i,j}  = [err_all{i,j};  p_sd  ];
        end
    end
end

figure('Position',[50 50 1200 1200]);
rng_ax   = [-4 4];
boundary = -3.8;            % ≈ lower-bound plateau of pruned parameters

for i = 1:3
    for j = 1:3
        x  = true_all{i,j};
        y  = rec_all{i,j};
        dy = err_all{i,j};

        % orange if value is stuck on lower boundary on *either* axis
        pflag = (x < boundary) | (y < boundary);

        subplot(3,3,(j-1)*3+i); hold on; box on;

        errorbar(x(~pflag), y(~pflag), dy(~pflag), dy(~pflag), ...
                 zeros(sum(~pflag),1), zeros(sum(~pflag),1), 'o', ...
                 'MarkerSize',4,'LineWidth',0.8,'Color',[0.2 0.2 0.6]);

        errorbar(x(pflag),  y(pflag),  dy(pflag),  dy(pflag),  ...
                 zeros(sum(pflag),1),  zeros(sum(pflag),1),  'o', ...
                 'MarkerSize',4,'LineWidth',0.8,'Color',[1 0.5 0]);

        plot(rng_ax,rng_ax,'k--','LineWidth',1);
        p  = polyfit(x,y,1); xx = linspace(rng_ax(1),rng_ax(2),100);
        plot(xx,polyval(p,xx),'r-','LineWidth',1);

        xm = mean(x);
        ym = mean(y);
        r2 = sum((x - xm) .* (y - ym))^2 / (sum((x - xm).^2) * sum((y - ym).^2));
        r2 = full(r2);
        text(0.02,-0.12,sprintf('R^2 = %.3f',r2),'Units','normalized','FontSize',8);



        xlabel('Simulated'); ylabel('Recovered');
        title(sprintf('%s fit / %s data',models{i},models{j}));
        axis square; xlim(rng_ax); ylim(rng_ax);
    end
end

