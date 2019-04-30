function [] = dataio_create_epochs_SSVEP_LARESI_playground(epoch_length, filter_band, set)
%DATAIO_CREATE_EPOCHS_SSVEP_LARESI_PLAYGROUND Summary of this function goes here
%   Detailed explanation goes here
% created : 11-14-2018
% last modified : -- -- --
% Okba Bekhelifi, <okba.bekhelif@univ-usto.dz>
% EEG structure: epochs     : struct
%                           :       : signal :  [samples channels trials]
%                           :       : events :  [1 trials]
%                           :       : y      :  [1 trials]
%                fs         : sampling rate
%                montage    : clab
%                classes    : classes {F1,...Fn}
%                paradigm   : struct
%                           :        : title : [str]
%                           :        : stimulation 1
%                           :        : pause 1
%                           :        : stimuli_count 1
%                           :        : type [str]
%                           :        : stimuli [1 stimuli_count]
%                subject    : (depending on the availability of info about
%                                 the subject)
tic
disp('Creating epochs for LARESI SSVEP dataset');
% set_path = 'datasets\LARESI_SSVEP\raw_mat';
Config_path_SM = 'datasets\epochs\ssvep_laresi\SM';
dataSetFiles = dir(['datasets\',set,'\*.mat']);
dataSetFiles = {dataSetFiles.name};
% set_path = [set_path,'\',dataSet{:}];

if(~exist(Config_path_SM,'dir'))
    mkdir(Config_path_SM);    
end

date_now = datestr(now);
date_now = strrep(date_now,' ','_');
date_now = strrep(date_now,':','_');
Config_path_SM = [Config_path_SM,'\',date_now];
nSubj = length(dataSetFiles);
trainEEG = cell(1);
filter_order = 6;
fs = 512; %
wnd = (epoch_length * fs) / 10^3;

for subj=1:nSubj
    disp(['Loading data for subject S0' num2str(subj)]);
    subject_path = ['datasets\',set,'\',dataSetFiles{subj}];
    load(subject_path);
    signal = eeg_filter(data.signal, data.fs, filter_band(1),filter_band(2), filter_order);
    trainEEG.epochs.signal = dataio_getERPEpochs(wnd, data.events.pos, signal);
    trainEEG.epochs.events = data.events.desc;
    trainEEG.epochs.y = data.events.y';
    trainEEG.fs = data.fs;
    trainEEG.montage.clab = data.montage;
    trainEEG.classes = data.paradigm.stimuli;
    trainEEG.paradigm = data.paradigm;
    trainEEG.subject.id = num2str(subj);
    trainEEG.subject.gender = '';
    trainEEG.subject.age = 0;
    trainEEG.subject.condition = 'healthy';
    disp(['Processing Train data succeed for subject: ' num2str(subj)]);
    if(~exist(Config_path_SM,'dir'))
        Config_path_SM = [Config_path_SM,'_',trainEEG.paradigm.type];
        mkdir(Config_path_SM);
    end
    save([Config_path_SM,'\','S0',num2str(subj),'trainEEG.mat'],'trainEEG', '-v7.3');
    clear signal trainEEG
end
toc
end
 

