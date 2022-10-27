function [StreamsRnd,RndIdx] = selectRandomStreamlines(Streams, NStreamlines)
    %% This function will move the points in Media along the streamlines Streams according to the speed in the streamline.
    % Function created by Baptiste Heiles on 21/06/29
    % Last modified on 21/12/06 to have the RndStreamlines output
    % Streams : cell containing the streamlines
    % NStreamline: scalar, number of streamlines to be taken
    % StreamsRnd: cell containing the streamlines selected

    RndIdx = randi(length(Streams), 1, NStreamlines); % Choose random streamlines
    StreamsRnd = Streams(RndIdx); % Fill the streams
    
end
