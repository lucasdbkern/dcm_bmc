%% Import the data in SPM 
% Configure the path and run tag
% -------------------------------------------------------------------------
datapath = fullfile(pwd, 'data', 'AEF');

spm('defaults', 'eeg');

dataset = 2;  
switch dataset
    case 1
        sub = 'sub-001'; 
        ses = 'ses-002'; 
        runs = {'run-002', 'run-003'}; 
    case 2
        sub  = 'sub-002'; 
        ses  = 'ses-001'; 
        runs = {'run-001', 'run-003'}; 
end
task = 'task-tone'; 
run  = runs{1};
trig = 'NI-TRIG-1'; 

spath = fullfile(datapath, sub, ses, 'meg');
stag  = [sub '_' ses '_' task '_' run]; 

% Read data into a MEEG object
% -------------------------------------------------------------------------
S = [];

S.data      = fullfile(spath, [stag '_meg.bin']); 
S.channels  = fullfile(spath, [stag '_channels.tsv']); 
S.meg       = fullfile(spath, [stag '_meg.json']); 
S.sMRI      = fullfile(datapath, sub, [sub '.nii']);
S.positions = fullfile(datapath, sub, ses, 'positions.tsv'); 

S.lead      = 1; 
S.meshres   = 2;

D = spm_opm_create(S);

%%

saturated_frames = whichDataSaturated(1e-6*D(indchantype(D, 'MEGMAG', 'GOOD'),:,1), 'n_sat_bins', 5, 'n_good_bins', 5, 'edge_step', 0.001);

all_sat_frames = cell2mat(saturated_frames');
all_sat_frames = unique(all_sat_frames);

if ~isempty(all_sat_frames)
    error('Add code to process saturated frames'); 
end


%% Filter the data

% Plot the PSD before filtering 
% -------------------------------------------------------------------------
S = []; 

S.triallength = 3000; 
S.plot        = 1;
S.D           = D;
S.channels    = 'MEG';

spm_opm_psd(S);
ylim([1,1e5])

% High-pass filter @ 2Hz
% -------------------------------------------------------------------------
S = [];

S.D    = D;
S.freq = 2;
S.band = 'high';

fD = spm_eeg_ffilter(S);

% Low-pass filter @ 64Hz
% -------------------------------------------------------------------------
S = [];

S.D    = fD;
S.freq = 64;
S.band = 'low';

fD = spm_eeg_ffilter(S);

% Band-pass filter @ 48-52Hz
% -------------------------------------------------------------------------
S = [];

S.D    = fD;
S.freq = [48, 52];
S.band = 'stop';

fD = spm_eeg_ffilter(S);

% Downsample to 256Hz
% -------------------------------------------------------------------------
S = []; 

S.D           = fD; 
S.fsample_new = 256; 

fD = spm_eeg_downsample(S); 

%% Apply Homogeneous Field Correction
S = [];

S.D = fD;
S.L = 1;

[hfD] = spm_opm_hfc(S);

%% Check data after preprocessing

% Mark flux channels as bad 
% -------------------------------------------------------------------------
% hfD = badchannels(hfD,29:34,1);
% hfD.save();

% Plot PSD after preprocessing
% -------------------------------------------------------------------------
S = []; 

S.triallength = 3000; 
S.plot        = 1;
S.D           = hfD;
S.channels    = 'MEG';

spm_opm_psd(S);
ylim([1,1e5])

%% ERP analysis

% Epoch the data around events
% -------------------------------------------------------------------------
S = [];

S.D               = hfD;
S.timewin         = [-100 400];
S.triggerChannels = {trig};

eD = spm_opm_epoch_trigger(S);

% Add in details about standard vs deviants
% -------------------------------------------------------------------------
snum = strsplit(sub, 'sub-'); 
csvfile = spm_select('FPList', fullfile(datapath, sub, ses, 'stim'), ...
    ['MMN_roving_' snum{2} '_' strrep(run, '-', '_') '.*']); 
csvfile = readtable(csvfile);
eD      = eD.conditions(':', csvfile.Condition);
eD.save(); 


%%

% Baseline-correct 
% -------------------------------------------------------------------------
S = [];

S.D       = eD;
S.timewin = [-100 0];

eD = spm_eeg_bc(S);



% Average 
% -------------------------------------------------------------------------
S = [];

S.D = eD;

muD = spm_eeg_average(S);
