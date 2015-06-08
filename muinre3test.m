function [config, store, obs] = muinre3test(config, setting, data)
% muinre2classification CLASSIFICATION step of the expCode project musicalInstrumentRecognition
%    [config, store, obs] = muinre2classification(config, setting, data)
%      - config : expCode configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date: 20-May-2015

% Set behavior for debug mode
if nargin==0, musicalInstrumentRecognition('do', 3, 'mask', {0 2 1 2 1 1 0 1}, 'host', 1.2); return; else store=[]; obs=[]; end

expRandomSeed();

dataStep1 = expLoad(config, [], 1);

features = dataStep1.features';

switch setting.test
    case 'train'
        selector = data.trainSelector;
    case 'test'
        selector = data.testSelector;
end

% scale data
features=bsxfun(@minus,features,min(features));
features=bsxfun(@rdivide,features,max(features));

features = features(selector, :);
store.instrument = dataStep1.instrument(selector)';
store.file = dataStep1.file(selector);

[store.prediction, accuracy, ~] = svmpredict(store.instrument, features, data.model, '-q');


obs.accuracy = accuracy(1)/100;

