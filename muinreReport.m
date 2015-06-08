function config = muinreReport(config)
% muinreReport REPORTING of the expCode project musicalInstrumentRecognition
%    config = muinreInitReport(config)
%       config : expCode configuration state

% Copyright: Mathieu Lagrange
% Date: 20-May-2015

if nargin==0, musicalInstrumentRecognition('report', 'r'); return; end

for k=1:3
    config = expExpose(config, 't', 'step', 4, 'mask', {k, 2, 1, 0, 1}, 'percent', 1, 'obs', 1);
end
