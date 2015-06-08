function [config, store, obs] = muinre2train(config, setting, data)
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
if nargin==0, musicalInstrumentRecognition('do', 2, 'mask', {0 2 1 2 1 1 1 1}); return; else store=[]; obs=[]; end

% scale data
features = data.features';
features=bsxfun(@minus,features,min(features));
features=bsxfun(@rdivide,features,max(features));

expRandomSeed();

switch  setting.dataset
    case 'solosDb'
        trainFiles = textread([config.codePath 'extra/train_SolodB.txt']);
        % build train vector
        trainSelector = zeros(1, length(data.file));
        for k=1:ceil(length(trainFiles)*setting.sampling/100)
            trainSelector(data.file==trainFiles(k)) = 1;
        end
        trainSelector = logical(trainSelector);
        
        testFiles= textread([config.codePath 'extra/test_SolodB.txt']);
        % build test vector
        testSelector = zeros(1, length(data.file));
        for k=1:ceil(length(testFiles)*setting.sampling/100)
            testSelector(data.file==testFiles(k)) = 1;
        end
        testSelector = logical(testSelector);
    otherwise
        % split in train and test (for each instrument take half of the files for testing)
        % select the files
        nbFilesPerInstrument = ceil(data.nbFilesPerInstrument*setting.sampling/100);
        fileIndexes = [1 cumsum(nbFilesPerInstrument)];
        trainFiles  = [];
        testFiles  = [];
        for k=1:length(data.instrumentLabels)
            trainFiles = [trainFiles fileIndexes(k):fileIndexes(k)+ceil(nbFilesPerInstrument(k)/2)];
            testFiles = [testFiles fileIndexes(k)+ceil(nbFilesPerInstrument(k)/2)+1:fileIndexes(k)+nbFilesPerInstrument(k)];
        end
        % build train vector
        trainSelector = zeros(1, length(data.file));
        for k=1:length(trainFiles)
            trainSelector(data.file==trainFiles(k)) = 1;
        end
        trainSelector = logical(trainSelector);
        testSelector = zeros(1, length(data.file));
        for k=1:length(testFiles)
            testSelector(data.file==testFiles(k)) = 1;
        end
        testSelector = logical(testSelector);
end

% learn
trainLabels = data.instrument(trainSelector)'; % 141196 368553 580855
trainData = features(trainSelector, :);

% if setting.sampling
%     selector = randi(length(trainLabels), 1, setting.sampling);
%     trainData = trainData(selector, :);
%     trainLabels = trainLabels(selector);
% end

switch setting.gamma
    case 0
        model = svmtrain(trainLabels, trainData, [' -t 0 -q -h ' num2str(setting.shrink)]);
    otherwise
        model = svmtrain(trainLabels, trainData, [' -h ' num2str(setting.shrink) ' -q -g ' num2str(setting.gamma)]);
end

[~, accuracy, ~] = svmpredict(trainLabels, trainData, model, '-q');

% store
store.trainSelector = trainSelector;
store.testSelector = testSelector;
store.model = model;

% obs
obs.trainAccuracy = accuracy(1)/100;