function [PredSignal,ActualData] = DecoderWrapperJ(timeframe, inputData, outputData,DecoderOptions,labels)
%% choose which data to use for the decoder

ninputs = size(inputData, 2);

binnedData.spikeratedata = inputData;
binnedData.neuronIDs = [ [1:ninputs]' zeros(ninputs, 1)];
binnedData.cursorposlabels = labels;
binnedData.timeframe = timeframe;
binnedData.cursorposbin = outputData; %DECODING SIGNAL


[PredSignal,ActualData] = epidural_mfxval_decoding(binnedData, DecoderOptions);
disp(PredSignal.mfxval.ave_vaf);  