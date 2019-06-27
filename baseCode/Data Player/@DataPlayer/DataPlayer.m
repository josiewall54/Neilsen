classdef DataPlayer

    properties
        currentFrame;%the frame currently being viewed
        videoData; %VideoData object
        ets; %EMGTimeSeries object
        windowSize; %seconds - the duration of the data to displays
        frameDur; %the duration (in seconds) of a frame
        nSamplePerFrame; %the number of sample points corresponding to 1 frame of video
        nSamplePerWindow; %the number of sample points to be displayed in one 'window' of data
    end

    methods
        function dataPlayer = DataPlayer(videoData, ets)
            
            dataPlayer.videoData = videoData;
            %store VideoData object in DataPlayer
            dataPlayer.ets = ets;
            %store EMGTimeSeries object in DataPlayer
            
            dataPlayer.currentFrame = 1;
            %initialize current frame to the first frame of the video
            dataPlayer.windowSize = 10;
            %initialize the windowSize to hold 10 seconds of data points (seconds - the duration of the data to displays)
            
            dataPlayer.frameDur = dataPlayer.videoData.getTimeFromFrame(2);
            %initialize the duration (in seconds) of a frame
            dataPlayer.nSamplePerFrame = dataPlayer.ets.getSampleFromTime(dataPlayer.frameDur);
            %initialize the number of sample points corresponding to 1 frame of video
            dataPlayer.nSamplePerWindow = dataPlayer.ets.getSampleFromTime(dataPlayer.windowSize);
            %initialize the number of sample points to be displayed in one 'window' of data
        end
        
        function dataPlayer = set.windowSize(obj, value)
            dataPlayer = obj;
            if (value < obj.frameDur)
                %make sure we're displaying a window big enough to display the
                %chunk of data of interest
                dataPlayer.windowSize = obj.frameDur;
                %sets window size (in seconds) so that it is big enough to hold data
                %points for at least one frame of data
            else
                dataPlayer.windowSize = value;
                %else sets window size (in seconds) to user's desired size 
            end
            dataPlayer.nSamplePerWindow = obj.ets.getSampleFromTime(dataPlayer.windowSize);
            %returns number of emg data samples to be displayed in the window
        end
        
        function dataPlayer = plotFrame(obj,frameNumber)
            dataPlayer = obj;
            if (frameNumber<1)
                frameNumber=1;
                %can't view a frame before the first frame of the video
            end
            if (frameNumber>dataPlayer.videoData.numberOfFrames)
                frameNumber=dataPlayer.videoData.numberOfFrames;
                %can't view a frame after the last frame of the video
            end
            dataPlayer.currentFrame = frameNumber;
            %sets the frame number to the number the frame number that the user would like to view

            videoFrame = dataPlayer.videoData.selectFrames(frameNumber);
            %calls VideoData's selectFrames function to load the frames,
            %deinterlace only the desired frames, and return on the frames
            %of interest

            emgDataStartSample = dataPlayer.ets.getSampleFromPulse(dataPlayer.videoData.nFirstFrame);
            emgDataStartSample = emgDataStartSample + dataPlayer.ets.getSampleFromTime(dataPlayer.videoData.getTimeFromFrame(frameNumber));
            %this is the first EMG data sample that corresponds to the
            %videoFrame
            
            %%%%junk: emgData = dataPlayer.ets.updateData(emgDataStartSample, emgDataStartSample + nPoints, 1);
     
            borderPoints = ceil((dataPlayer.nSamplePerWindow - dataPlayer.nSamplePerFrame)/2);
            %the number of points which will surround the chunk of data of interest
            
            %%%%junk: windowData - the data that will be displayed in the end
            %%%%junk: windowStartTime,windowStopTime
            %%%%junk: windowStartSample,windowStopSample
            %%%%junk: emgDataStartTime - the time of the EMG chunk of interest

            windowStartSample = emgDataStartSample-borderPoints;
            %first sample of EMG data to be displayed (including borderPoints)
            windowStopSample  = windowStartSample-1+dataPlayer.nSamplePerWindow;
            %last sample of EMG data to be displayed (including borderPoints)

            if (windowStartSample<1)
                windowStartSample = 1;
                windowStopSample = dataPlayer.nSamplePerWindow;
                %can't view the data point before the first data point of
                %the EMG data set
            end
            if (windowStopSample>dataPlayer.ets.totNumSamples)
                windowStartSample=dataPlayer.ets.totNumSamples-dataPlayer.nSamplePerWindow;
                windowStopSample=dataPlayer.ets.totNumSamples;
                %can't view the data point after the last data point of
                %the EMG data set
            end

            %get the Data
            dataPlayer.ets = dataPlayer.ets.updateData(windowStartSample, windowStopSample, dataPlayer.ets.downSample);

            %plot video Frame and Data side by side
            subplot(2,1,1);
            image(videoFrame);
            subplot(2,1,2);
            dataPlayer.ets.plot();

            %%%%junk:          %calculate the times
            %%%%junk:        windowStartTime = dataPlayer.ets.getTimeFromSample(windowStartSample);
            %%%%junk:        windowStopTime  = dataPlayer.ets.getTimeFromSample(windowStopSample );
            %%%%junk:          emgDataStartTime = dataPlayer.ets.getTimeFromSample(emgDataStartSample);
            %%%%junk: 
            %%%%junk:              if((emgDataStartSample+nPoints+25000)>dataPlayer.ets.totNumSamples)
            %%%%junk:                 emgDataDisplay = dataPlayer.ets.updateData(1, dataPlayer.ets.totNumSamples, 1);
            %%%%junk:              else
            %%%%junk:                  emgDataDisplay = dataPlayer.ets.updateData(1, emgDataStartSample + nPoints + 25000, 1);
            %%%%junk:              end
            %%%%junk:         else
            %%%%junk:              if((emgDataStartSample+nPoints+25000)>dataPlayer.ets.totNumSamples)
            %%%%junk:                  emgDataDisplay = dataPlayer.ets.updateData(emgDataStartSample-25000, dataPlayer.ets.totNumSamples, 1);
            %%%%junk:              else
            %%%%junk:                  emgDataDisplay = dataPlayer.ets.updateData(emgDataStartSample-25000, emgDataStartSample + nPoints + 25000, 1);
            %%%%junk:              end
            %%%%junk:          end
            %%%%junk:         emgDataDisplay = emgDataDisplay;
        end

        function dataPlayer = plotNextFrame(obj)
            %plots the frame following the current frame
            dataPlayer = obj;
            if (dataPlayer.currentFrame==dataPlayer.videoData.numberOfFrames)
                display('Already at last frame');
                %checks to see if you are at the last frame
            else
                %%%%junk: dataPlayer = dataPlayer.plotFrame(dataPlayer.currentFrame + 1);
                
                %get the next frame
                dataPlayer.currentFrame = dataPlayer.currentFrame + 1;
                videoFrame = dataPlayer.videoData.selectFrames(dataPlayer.currentFrame);
                %shift the emg data nSamplePerFrame points to the left
                data = dataPlayer.ets;
                dimOut = 1:(dataPlayer.nSamplePerWindow-dataPlayer.nSamplePerFrame);
                [nbLines, nbCols] = size(data.Data);
                dimIn = (dataPlayer.nSamplePerFrame+1):nbLines;
                dataIn = data.Data(dimIn,:);
                data.Data(dimOut, :)= dataIn;
                %get the index of the data to be read by labviewreadfile
                nsamp1 = dataPlayer.ets.nsamp1 + (dataPlayer.nSamplePerWindow-dataPlayer.nSamplePerFrame) + 1;
                nsamp2 = nsamp1 + dataPlayer.nSamplePerFrame;
                sampleRange = [nsamp1 nsamp2];
                [info, dat, time] = readlabviewfile(dataPlayer.ets.fileName, sampleRange, dataPlayer.ets.downSample);
                %append the new chunk of data to the right
                data.Data((dataPlayer.nSamplePerWindow-dataPlayer.nSamplePerFrame):end,:) = dat';
                
                %update the ets obj
                dataPlayer.ets.nsamp1 = dataPlayer.ets.nsamp1 + dataPlayer.nSamplePerFrame;
                dataPlayer.ets.nsamp2 = dataPlayer.ets.nsamp2 + dataPlayer.nSamplePerFrame;
                dataPlayer.ets.Data = data.Data;
                dataPlayer.ets.Time = dataPlayer.ets.Time + dataPlayer.frameDur;
                
                %plot
                subplot(2,1,1);
                image(videoFrame);
                subplot(2,1,2);
                data.plot();
            end
        end
        
        function dataPlayer = plotPrevFrame(dataPlayer)
             %plots the frame preceding the current frame
            if (dataPlayer.currentFrame==1)
                display('Already at first frame');
            else
                %dataPlayer = dataPlayer.plotFrame(dataPlayer.currentFrame - 1);

                %get the prev frame
                dataPlayer.currentFrame = dataPlayer.currentFrame - 1;
                videoFrame = dataPlayer.videoData.selectFrames(dataPlayer.currentFrame);
                %shift the emg data nSamplePerFrame points to the right
                data = dataPlayer.ets;
                data.Data(dataPlayer.nSamplePerFrame+1:end,:) = data.Data(1:(dataPlayer.nSamplePerWindow-dataPlayer.nSamplePerFrame),:);
                %get the index of the data to be read by labviewreadfile
                nsamp1 = dataPlayer.ets.nsamp1 - dataPlayer.nSamplePerFrame - 1;
                nsamp2 = nsamp1 + dataPlayer.nSamplePerFrame - 1;
                sampleRange = [nsamp1 nsamp2];
                [info, dat, time] = readlabviewfile(dataPlayer.ets.fileName, sampleRange, dataPlayer.ets.downSample);
                %append the new chunk of data to the right
                data.Data(1:dataPlayer.nSamplePerFrame,:) = dat';
                
                
                %update the ets obj
                dataPlayer.ets.nsamp1 = dataPlayer.ets.nsamp1 + dataPlayer.nSamplePerFrame;
                dataPlayer.ets.nsamp2 = dataPlayer.ets.nsamp2 + dataPlayer.nSamplePerFrame;
                dataPlayer.ets.Data = data.Data;
                dataPlayer.ets.Time = dataPlayer.ets.Time - dataPlayer.frameDur;
                
                %plot
                subplot(2,1,1);
                image(videoFrame);
                subplot(2,1,2);
                data.plot();
            end
        end
        
        function dataPlayer = getData(obj,frameNumberStart, frameNumberEnd)
            dataPlayer = obj;
            if (frameNumberStart<1)
                frameNumberStart=1;
                %can't view a frame before the first frame of the video
            end
            if (frameNumberEnd >dataPlayer.videoData.numberOfFrames)
                frameNumberEnd=dataPlayer.videoData.numberOfFrames;
                %can't view a frame after the last frame of the video
            end
            
            frameNumbers=[frameNumberStart, frameNumberEnd];
            videoFrames = dataPlayer.videoData.selectFrames(frameNumbers);
            dataPlayer.videoData.selectedFrames = videoFrames;
            %calls VideoData's selectFrames function to load the frames,
            %deinterlace only the desired frames, and return on the frames
            %of interest

            videoStartSample = dataPlayer.ets.getSampleFromPulse(dataPlayer.videoData.nFirstFrame);
            emgDataStartSample = videoStartSample + dataPlayer.ets.getSampleFromTime(dataPlayer.videoData.getTimeFromFrame(frameNumberStart));
            %this is the EMG data sample that corresponds to the beginning of the video chunk of interest

            emgDataEndSample = videoStartSample + dataPlayer.ets.getSampleFromTime(dataPlayer.videoData.getTimeFromFrame(frameNumberEnd));
            %this is the last EMG data sample that corresponds to the end of the video chunk of interest
            sampleRange = [emgDataStartSample emgDataEndSample];
            [info, dat, time] = readlabviewfile(dataPlayer.ets.fileName, sampleRange, dataPlayer.ets.downSample);
            dataPlayer.ets.Data = dat';
            dataPlayer.ets.Time = time;
        end
    end
end