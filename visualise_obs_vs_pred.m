% function visualise_obs_vs_pred
% % 
% %  % Load the DCM
% load('DCM_25-Jul-2024.mat','DCM');
% 
% % Get spatial projector (or identity)
% try
%     U = DCM.M.U';
% catch
%     U = 1;
% end
% 
% % Define conditions (assumes trial 1 = Standard, trial 2 = Deviant)
% obsStandard  = (DCM.H{1} + DCM.R{1}) * U;
% predStandard = DCM.H{1} * U;
% obsDeviant   = (DCM.H{2} + DCM.R{2}) * U;
% predDeviant  = DCM.H{2} * U;
% 
% % Get time and channel info
% t  = DCM.xY.pst;
% ne = size(DCM.xY.y{1},2);
% 
% % Compute global dynamic range over all conditions
% allData = [obsStandard(:); predStandard(:); obsDeviant(:); predDeviant(:)];
% gmin = min(allData);
% gmax = max(allData);
% 
% % Create figure
% figure('Name','Observed vs Predicted: Standard vs Deviant','Position',[100 100 1200 600]);
% 
% % Top-left: Observed - Deviant
% subplot(2,2,1)
% imagesc(t, 1:ne, obsStandard', [gmin gmax]);
% xlabel('Time (ms)'); ylabel('Channels');
% title('Observed - Deviant');
% axis square; grid on;
% colorbar;
% 
% % Top-right: Predicted - Deviant
% subplot(2,2,2)
% imagesc(t, 1:ne, predStandard', [gmin gmax]);
% xlabel('Time (ms)'); ylabel('Channels');
% title('Predicted - Deviant');
% axis square; grid on;
% colorbar;
% 
% % Bottom-left: Observed - Standard
% subplot(2,2,3)
% imagesc(t, 1:ne, obsDeviant', [gmin gmax]);
% xlabel('Time (ms)'); ylabel('Channels');
% title('Observed - Standard');
% axis square; grid on;
% colorbar;
% 
% % Bottom-right: Predicted - Standard
% subplot(2,2,4)
% imagesc(t, 1:ne, predDeviant', [gmin gmax]);
% xlabel('Time (ms)'); ylabel('Channels');
% title('Predicted - Standard');
% axis square; grid on;
% colorbar;
% 
% % Set colormap (e.g., jet) as desired
% %colormap(redbluecmap);
% myMap = cbrewer2('div', 'RdBu', 256);
% myMap = flipud(myMap);
% colormap(myMap);
% end

% 
% function visualise_obs_vs_pred
% % Observed vs. predicted; cyan-to-white-to-purple, zero = white
% 
% load('DCM_25-Jul-2024.mat','DCM');
% 
% try, U = DCM.M.U'; catch, U = 1; end
% 
% obsStandard  = (DCM.H{1}+DCM.R{1})*U;
% predStandard =  DCM.H{1}*U;
% obsDeviant   = (DCM.H{2}+DCM.R{2})*U;
% predDeviant  =  DCM.H{2}*U;
% 
% t  = DCM.xY.pst;
% ne = size(DCM.xY.y{1},2);
% allData = [obsStandard(:); predStandard(:); obsDeviant(:); predDeviant(:)];
% gmin = min(allData); gmax = max(allData);
% 
% 
% n  = 256;
% 
% c_neg = hex2rgb('#24dbdb');   % cyan-turquoise
% c_pos = hex2rgb('#5e4fa2');   % indigo-violet
% ratio = (-gmin)/(gmax-gmin);
% w_idx = max(1,min(n,round(ratio*(n-1))+1));
% neg_len = w_idx;     pos_len = n-w_idx+1;
% 
% neg = [linspace(c_neg(1),1,neg_len)', ...
%        linspace(c_neg(2),1,neg_len)', ...
%        linspace(c_neg(3),1,neg_len)'];
% pos = [linspace(1,c_pos(1),pos_len)', ...
%        linspace(1,c_pos(2),pos_len)', ...
%        linspace(1,c_pos(3),pos_len)'];
% cmap = [neg; pos(2:end,:)];
% 
% amin = 0.0275; amax = 1;
% 
% figure('Name','Observed vs Predicted: Standard vs Deviant','Position',[100 100 1200 600]);
% 
% subplot(2,2,1); showImage(obsStandard ,t,ne,gmin,gmax,amin,amax); title('Observed – Standard');
% subplot(2,2,2); showImage(predStandard,t,ne,gmin,gmax,amin,amax); title('Predicted – Standard');
% subplot(2,2,3); showImage(obsDeviant  ,t,ne,gmin,gmax,amin,amax); title('Observed – Deviant');
% subplot(2,2,4); showImage(predDeviant ,t,ne,gmin,gmax,amin,amax); title('Predicted – Deviant');
% 
% colormap(cmap);
% end
% 
% % ---------- helpers ----------
% function showImage(data,t,ne,gmin,gmax,amin,amax)
%     h = imagesc(t,1:ne,data',[gmin gmax]);
%     axis square; grid on; xlabel('Time (ms)'); ylabel('Channels');
%     normd = (data-gmin)./(gmax-gmin);
%     h.AlphaData = amin + normd'*(amax-amin);
%     colorbar;
% end
% 
% function rgb = hex2rgb(hex)
%     if hex(1)=='#', hex = hex(2:end); end
%     rgb = reshape(sscanf(hex(1:6),'%2x')',[3 1])/255;
% end



function visualise_obs_vs_pred
%load('DCM_25-Jul-2024.mat','DCM');
DCM = load("subject_folder/subject_15/derivatives/DCMij.mat").DCMij{3,3};
try, U = DCM.M.U'; catch, U = 1; end

obsS = (DCM.H{1}+DCM.R{1})*U;  predS = DCM.H{1}*U;
obsD = (DCM.H{2}+DCM.R{2})*U;  predD = DCM.H{2}*U;

t  = DCM.xY.pst;
ne = size(DCM.xY.y{1},2);
L  = max(abs([obsS(:); predS(:); obsD(:); predD(:)]));

c_neg = hex2rgb('#24dbdb'); c_pos = hex2rgb('#5e4fa2');
n = 256; w = n/2;
neg = [linspace(c_neg(1),1,w)', linspace(c_neg(2),1,w)', linspace(c_neg(3),1,w)'];
pos = [linspace(1,c_pos(1),w)', linspace(1,c_pos(2),w)', linspace(1,c_pos(3),w)'];
cmap = [neg; pos];

figure('Position',[100 100 1200 600]);
subplot(2,2,1); show(obsS ,t,ne,L,'Observed – Standard');
subplot(2,2,2); show(predS,t,ne,L,'Predicted – Standard');
subplot(2,2,3); show(obsD ,t,ne,L,'Observed – Deviant');
subplot(2,2,4); show(predD,t,ne,L,'Predicted – Deviant');
colormap(cmap);

end 

% ------------ helpers ------------
function show(data,t,ne,L,ttl)
imagesc(t,1:ne,data',[-L L]); axis square; grid on;
xlabel('Time (ms)'); ylabel('Channels'); title(ttl); colorbar;
end

function rgb = hex2rgb(hex)
if hex(1)=='#', hex = hex(2:end); end
rgb = reshape(sscanf(hex,'%2x')',1,3)/255;
end


