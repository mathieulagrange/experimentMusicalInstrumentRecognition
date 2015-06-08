function [config, store] = muinreInit(config)                                  
% muinreInit INITIALIZATION of the expCode project musicalInstrumentRecognition
%    [config, store] = muinreInit(config)                                      
%      - config : expCode configuration state                                  
%      -- store  : processing data to be saved for the other steps             
                                                                               
% Copyright: Mathieu Lagrange                                                  
% Date: 20-May-2015                                                            
                                                                               
if nargin==0, musicalInstrumentRecognition(); return; else store=[];  end      
