function [config, store, obs] = muinre4vote(config, setting, data)
% muinre4vote VOTE step of the expCode project musicalInstrumentRecognition
%    [config, store, obs] = muinre4vote(config, setting, data)
%      - config : expCode configuration state
%      - setting   : set of factors to be evaluated
%      - data   : processing data stored during the previous step
%      -- store  : processing data to be saved for the other steps
%      -- obs    : observations to be saved for analysis

% Copyright: Mathieu Lagrange
% Date: 04-Jun-2015

% Set behavior for debug mode
if nargin==0, musicalInstrumentRecognition('do', 4, 'mask', {0 2 1 2 1 1}); return; else store=[]; obs=[]; end

switch setting.votingWindow
    case 1 % no integration
        accuracy = data.instrument==data.prediction;
    otherwise % integration per number specified
        accuracy=[];
        files = unique(data.file);
        for k=1:length(files)
            instrument = data.instrument(data.file==files(k));
            vote = data.prediction(data.file==files(k));
            
            attackTime = ceil(length(instrument)*setting.attackDuration/100);
            
            switch setting.votingArea
                case 'attack'
                    instrument = instrument(1:attackTime);
                    vote = vote(1:attackTime);
                case 'sustain'
                    instrument = instrument(round(((end-attackTime):(end+attackTime))/2));
                    vote = vote(round(((end-attackTime):(end+attackTime))/2));
            end
            
            if   ~setting.votingWindow % integration per file
                nbVotes = 1;
                windowSize = length(instrument);
            else
                windowSize = setting.votingWindow;
                nbVotes = floor(length(instrument)/windowSize);
            end
            for m=1:nbVotes
                vi = instrument(1+(m-1)*windowSize:m*windowSize);
                vv= vote(1+(m-1)*windowSize:m*windowSize);
                
                [cardinality, value] = hist(vi, unique(vi));
                value(cardinality==0)=[];
                if length(value)>1, error('ground truth shall be unique'); end
                vi = value;
                
                [cardinality, value] = hist(vv, unique(vv));
                [maxV, maxC] = max(cardinality);
                vv = value(maxC(1));
                accuracy(end+1) = vv==vi;
            end
        end
        
end

obs.cardinality = length(accuracy);
obs.accuracy = accuracy;