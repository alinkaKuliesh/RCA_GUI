function [StreamsAvailableData,StreamsPickedData,StreamsAvailableIdx,StreamsPickedIdx,StreamsLeftIdx,P]=MakeSubsetOfStreams(P,StreamsRnd,StreamsIdx)
    %% This function will create subsets from the input StreamsRnd and StreamsIdx
    % Function created by Baptiste Heiles on 22/07/22
    % Last modified on 22/07/22
    % Input :
    %       P : structure containg the parameters for the MB generation module
    %       StreamsRnd : list of cells containing streams to choose from
    %       StreamsIdx : list of cell containing the indices of the streams in
    % Output : 
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
    
    StreamsAvailableData=vertcat(StreamsRnd{:});
    % Shift the time to take into account backward propagation
    for i_s=1:size(StreamsAvailableData,1)
        if min(StreamsAvailableData{i_s}(:,1))<0
            StreamsAvailableData{i_s}(:,1)=StreamsAvailableData{i_s}(:,1)-min(StreamsAvailableData{i_s}(:,1));% substract the negative time
            StreamsAvailableData{i_s}=flipud(StreamsAvailableData{i_s});% flip it up and down to have time=0s first
        end
    end
    AllStreamsIdx=vertcat(StreamsIdx{:});
    tempStream=cell2mat(StreamsAvailableData);
    if isempty(P.MaxDuration)
        P.MaxDuration=(max(tempStream(:,1)));% Maximum duration of a streamline in second
    end
    time_vector=0:1/P.FrameRate:P.MaxDuration;
    clear tempStream

    StreamsPickedIdx=[1:P.NMicrobubbles];StreamsAvailableIdx=[1:size(StreamsAvailableData,1)];StreamsLeftIdx=[];
    CurrentStreamsIdx=[1:P.NMicrobubbles];
    StreamsPickedData=StreamsAvailableData(StreamsPickedIdx);
end
