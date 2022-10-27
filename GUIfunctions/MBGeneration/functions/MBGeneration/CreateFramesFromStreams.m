function CreateFramesFromStreams(P,time_vector,StreamsAvailableData,StreamsPickedData,StreamsAvailableIdx,StreamsPickedIdx,StreamsLeftIdx)
    %% This function will create the Frames structures based on the parameters, time_vector and all the streams
    % Function created by Baptiste Heiles on 22/07/22
    % Last modified on 22/07/22
    % Input : 
    %       P : structure containg the parameters for the MB generation module
    %       time_vector : a vector containing the sampling time in seconds
    %       StreamsAvailableData : list of cells containing the streams that are
    %           available to pick
    %       StreamsPickedData : list of cells containing the streams that have
    %           been picked
    %       StreamsAvailableIdx : list of cells containing the indices of the
    %           streams in StreamsAvailableData
    %       StreamsPickedIdx : list of cells containing the indices of the
    %           streams in StreamsPickedData
    %       StreamsLeftIdx : list of cells containing the indices of the
    %           streams left to be picked (available-picked)
    
    
    countFrame=1;
    countWarning=0;
    timestamp=datestr(now,'yy_mm_dd_hh_MM');
    NumOfFramesPadding=num2str(length(num2str(round(time_vector(end).*P.FrameRate))));% Find out how many zero padding you'll need for file name
    CurrentStreamsIdx=StreamsPickedIdx;
    % Create the frame structures (est time 26 s)
    for idx_Frame=time_vector
        Frame=[];% reinitialize frame at each time
        countMBPerFrame=1;

        for idx_MB=1:P.NMicrobubbles

            % Quick check to make sure you have not reached the maximum
            % duration of the streamline
            if max(abs(StreamsPickedData{idx_MB}(:,1)))<idx_Frame % if the idx_Frame is higher then you've reached the end of the streamline's duration
                % Pick the next stream left to repropagate a MB
                StreamsLeftIdx=setdiff(StreamsAvailableIdx,StreamsPickedIdx);% Exclude the streams already picked

                if isempty(StreamsLeftIdx) % if you have no more streams then loop again but display a warning
                    countWarning=countWarning+1;
                    warning('on');warning([num2str(countWarning),'. Passed through all the streamlines, will loop again']);
                    StreamsLeftIdx=StreamsAvailableIdx(randperm(size(StreamsAvailableIdx,2),size(StreamsAvailableIdx,2)));
                end

                NewStreamIdx=StreamsLeftIdx(1);% Take the first of the streams left
                StreamsPickedIdx(end+1)=NewStreamIdx;% Store the new stream index to the StreamsPickedIdx array
                CurrentStreamsIdx(idx_MB)=NewStreamIdx;
                StreamsPickedData{idx_MB}=StreamsAvailableData{NewStreamIdx};
                StreamsPickedData{idx_MB}(:,1)=StreamsPickedData{idx_MB}(:,1)+idx_Frame;% and offset the initial time by the idx_Frame
            end

            % Now calculate MB point, velocity position
            [points,velocities,mmin]=StreamToFrame(StreamsPickedData{idx_MB},idx_Frame,P.FrameRate);

            % Reconstruct the Frame structure
            Frame.Points(countMBPerFrame,:)=points;
            Frame.VelocityFromStream(countMBPerFrame,:)=velocities;
            Frame.Diameter(countMBPerFrame,:)=round(P.MBDistribS(idx_MB)*10)./10;% round up to a micrometer
            Frame.StreamNumber(countMBPerFrame,:)=CurrentStreamsIdx(idx_MB);

            % Increase MB per frame counter
            countMBPerFrame=countMBPerFrame+1;
        end

        if isempty(Frame);disp('Empty Frame');return;end

        try
            save([P.path_to_simulation,'\MBframes_',timestamp,'\Frame_',num2str(countFrame,['%0',NumOfFramesPadding,'i']),'.mat'],'Frame');
        catch
            mkdir([P.path_to_simulation,'\MBframes_',timestamp,'\']);
            save([P.path_to_simulation,'\MBframes_',timestamp,'\Frame_',num2str(countFrame,['%0',NumOfFramesPadding,'i']),'.mat'],'Frame');
        end

        countFrame=countFrame+1;
        drawnow
    end
end