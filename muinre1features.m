function [config, store, obs] = muinre1features(config, setting, data)
% muinre1features FEATURES step of the expCode project musicalInstrumentRecognition
%    [config, store, obs] = muinre1features(config, setting, data)
%      - config : expCode configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date: 20-May-2015

% Set behavior for debug mode
if nargin==0, musicalInstrumentRecognition('do', 1, 'store', 0); return; else store=[]; obs=[]; end

% instruments = {'Ba'  'Bo'  'Cl'  'Co'  'Fh'  'Fl'  'Ob'  'Pn'  'Sa'  'Ta'  'Tb'  'Tr' 'Va'  'Vl'};
switch setting.dataset
    case 'solosDb'
        instruments = {'Cl'  'Co'  'Fh'  'Ob' 'Gt'  'Pn'   'Tr'  'Vl'};
    otherwise
        instruments = {'Cl'  'Co'  'Fh'  'Ob'  'Pn'   'Tr'  'Vl'};
end

if config.store
    features = [];
    instrument = [];
    file = [];
    fileId = 0;
    for k=1:length(instruments)
        files = dir([config.inputPath setting.dataset '/' instruments{k} '/*.wav']);
        for m=1:length(files)
            [a, fs] = wavread([config.inputPath setting.dataset '/'  instruments{k} '/' files(m).name]);
            
            switch setting.features
                case 'mel'
                    [mfcc, feature] = melfcc(a);
                    envelope = mfcc(1, :);
                case 'mfcc'
                    feature = melfcc(a);
                    envelope = feature(1, :);
            end
            feature(:, isnan(sum(feature))) = [];
            feature(:, isinf(sum(feature))) = [];
            for n=1:floor(size(feature, 2)/setting.textureWindow)
                textureFeature(:, n) = mean(feature(:, (n-1)*setting.textureWindow+1:n*setting.textureWindow), 2);
                textureEnvelope(n) =  mean(envelope((n-1)*setting.textureWindow+1:n*setting.textureWindow));
            end
            envelope=textureEnvelope;
            feature = textureFeature(:, envelope>max(envelope)-30);
            envelope(envelope<max(envelope)-30)=[];
            features = [features feature];
            
            instrument = [instrument ones(1, size(feature, 2))*k];
            switch  setting.dataset
                case 'solosDb'
                    [p, n]=fileparts(files(m).name);
                    fileId = str2num(n);
                otherwise
                    fileId = fileId+1;
            end
            
            file = [file ones(1, size(feature, 2))*fileId];
        end
        nbFilesPerInstrument(k) = length(files);
    end
    
    store.features = features;
    store.instrumentLabels= instruments;
    store.instrument= instrument;
    store.file = file;
    store.nbFilesPerInstrument = nbFilesPerInstrument;
else
    store = data.store;
end

obs.nbFiles = sum(store.nbFilesPerInstrument);
obs.nbWindow = length(store.file);
obs.nbFilesPerInstrument = store.nbFilesPerInstrument;