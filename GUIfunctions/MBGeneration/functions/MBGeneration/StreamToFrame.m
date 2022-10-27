function [points,velocities,mmin]=StreamToFrame(Streams,FrameIdx,FrameRate)
% A function to translate the streamline's characteristics to the frame
% structure.

    % Find closest sample in StreamRnd to the idx_Frame time with a
    % precision of a millisecond (assuming StreamsRnd is already in
    % seconds)
    [mmin,ind]=min(abs(round(Streams(:,1).*1E3)-FrameIdx*1E3));
    
    if mmin<50 % if it's below 200 milliseconds

        points=Streams(ind,5:7);% One stream=one microbubble
        velocities=Streams(ind,2:4);
    else % then you don't have a good sample and we will assume a constant velocity between two time-steps
        if ind>1
            points=Streams(ind-1,5:7)+Streams(ind-1,2:4).*(FrameIdx-Streams(ind-1,1));
            velocities=Streams(ind-1,2:4);
        else
            points=Streams(ind,5:7)+Streams(ind,2:4).*(FrameIdx-Streams(ind,1));
            velocities=Streams(ind,2:4);
        end
    end
end