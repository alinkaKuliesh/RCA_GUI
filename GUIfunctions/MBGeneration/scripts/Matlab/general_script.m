%% Script to generate streamlines for Alina with the mouse brain data
% Created by Baptiste Heiles on 22/05/30
% Last modified on 22/05/30

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get paths and define P struct %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add relevant paths and load streamlines
P.path_to_Github='C:\Users\bheiles\Documents\Github\';
addpath(genpath([P.path_to_Github,'BIS\functions']));
P.path_to_streams='P:\2021\Data\BIS\renal\Sim1_mt8E4_is30_msl3E5_ConnEdges\';% path to the csv files containing the streamlines
P.path_to_streamsCells=[P.path_to_streams,'StreamsAsCells\'];% path where you want to save the cell containing streamlines
P.path_to_simulation='P:\2021\Data\BIS\renal\Sim1_mt8E4_is30_msl3E5_ConnEdges\Matlab\';% path where you want to save the simulated positions
P.path_to_data='C:\Users\bheiles\Documents\Github\BIS\data\';% path for Sonovue distribution
listCSV=dir([P.path_to_streams,'streamline*.csv']);
pd=importdata([P.path_to_data,'\Sonovue_distribution\sonovuepd.mat']);% Import bubble distribution

%% Create the saving folder
[sta,msg]=mkdir(P.path_to_simulation);
if sta;warning(msg);end % notify with warning

%% List parameters
P.V_scale=[1;1;1].*1E-6;% Velocity scaling to m/s : 1x3 vector (when saving velocity_scaled in the python script)
P.X_scale=[1;1;1].*1E-6;% Point scaling to meters : 1x3 vector (mesh is in micrometers)
P.t_scale=1;% Time scaling to seconds
P.NStreamlineFile=120;% Number of files containing streamlines to be taken (size(dir([P.path_to_streams,'StreamsAsCells\*.mat']),1)))
P.NStreamlinePerFile=1;% Max number of streamline to be taken from each file this would mean more microbubble per individual vessel
P.NSpecklePoints=0;% Choose a number of speckle points (optional to generate speckle)
P.ScaleSwitch=0;% If you want to scale your media or not (optional)
P.isRandom=1;% Logical to select random streamlines in each file. If set to 0, it will just take the first P.NStreamlinePerFile
P.NMicrobubbles=10;
P.FrameRate=500;% In Hz
P.MaxDuration = [];% in s (leave empty to let the algorithm pick the maximum duration of a streamline)
P.minSpeed=8E-3;% min speed parameter for the conversion of the streamlines
P.minLength=100E-6;% min length parameter for the conversion of streamlines


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Convert data into cells .mat %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic % est time 52 s
mkdir(P.path_to_streamsCells);

ConvertDataToCells(P);
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create simulation frames %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkdir(P.path_to_simulation)
% Get list of streamlines
listStreamlines=dir([P.path_to_streamsCells,'Streams*.mat']);
listStreamlineFiles=randperm(size(listStreamlines,1),P.NStreamlineFile);% Randomize

%% Select the streamlines subset from which you want to simulate the MBs on and save them in a folder
clear StreamsRnd StreamsIdx;StreamsRnd{1}=[];StreamsIdx=[];
countIdx=1;
for idx_file=listStreamlineFiles
    count_Streams=size(StreamsRnd,1);
    load([listStreamlines(idx_file).folder,'\',listStreamlines(idx_file).name]);

    NStreamlines=min(P.NStreamlinePerFile,size(Streams,1));% Choose a number of streamlines to be simulated
    
    if P.isRandom==1% Random distribution allowing repeats
        [tempStreams,tempIdx] = selectRandomStreamlines(Streams, NStreamlines);
    else
        tempIdx=1:NStreamlines;
        tempStreams=Streams(tempIdx);
    end
    StreamsRnd{countIdx}=tempStreams;% Each cell will contain random streamlines
    StreamsIdx{countIdx}=tempIdx';% Each cell will contain the index of the streamlines taken
    countIdx=countIdx+1;
end
StreamsRnd=StreamsRnd(~cellfun(@isempty,StreamsRnd));
save([P.path_to_simulation,'\StreamsRnd.mat'],'StreamsRnd','StreamsIdx');

%% Clean microbubble distribution
P.MBDistrib=exprnd(pd.mu,1E4);% generate large distribution sizes
P.MBDistrib(P.MBDistrib<0.7)=[];P.MBDistrib(P.MBDistrib>10)=[];% remove unwanted sizes (problematic?)
P.MBDistribS=P.MBDistrib(randi(size(P.MBDistrib,2),1,P.NMicrobubbles));% pick uniformly distributed sizes in the previous distribution

%% Choose the streams you want to create from
load([P.path_to_simulation,'StreamsRnd.mat']);
[StreamsAvailableData,StreamsPickedData,StreamsAvailableIdx,StreamsPickedIdx,StreamsLeftIdx,P]=MakeSubsetOfStreams(P,StreamsRnd,StreamsIdx);


%% Create frames from streams (est time: 343 s)
time_vector=0:1/P.FrameRate:P.MaxDuration;
tic
CreateFramesFromStreams(P,time_vector,StreamsAvailableData,StreamsPickedData,StreamsAvailableIdx,StreamsPickedIdx,StreamsLeftIdx)
toc

%% Visualize MBs after generation
figure;
cmap=winter(size(StreamsPickedIdx,2));
for i_s=1:size(StreamsPickedIdx,2)
    t=StreamsAvailableData{StreamsPickedIdx(i_s)};
    plot3(t(:,5),t(:,6),t(:,7),'LineWidth',0.1,'Color',cmap(i_s,:));daspect([1,1,1]);grid on;
    hold on
end
listframes=dir([P.path_to_simulation,'\MBframes_',timestamp,'\*.mat']);
for i_f=1:size(listframes,1)
    load([listframes(i_f).folder,'\',listframes(i_f).name]);
    plot3(Frame.Points(:,1),Frame.Points(:,2),Frame.Points(:,3),'o','MarkerEdgeColor','k');
    title(['Real time = ',num2str(i_f.*1./P.FrameRate),' s']);hold on;drawnow;pause(0.1);
end


