clear all
% load standard Microbbuble and Medium GUI parameters
load('/Users/akuliesh1/RCA_GUI/GUI_output_parameters.mat', 'Microbubble', 'Medium')

%%
Medium.Inhomogeneity = 0;
Medium.InhomogeneityCutoff = 2;
Medium.SpeedOfSoundMinimum = Medium.SpeedOfSound*(1-Medium.Inhomogeneity*Medium.InhomogeneityCutoff);
Medium.SpeedOfSoundMaximum = Medium.SpeedOfSound*(1+Medium.Inhomogeneity*Medium.InhomogeneityCutoff);

%%
Transmit.CenterFrequency = 15.625e6; % [Hz]

%%
SimulationParameters.CFL = 0.3;
SimulationParameters.PointsPerWavelength = 8;
SimulationParameters.GridSize = Medium.SpeedOfSound / Transmit.CenterFrequency /...
    SimulationParameters.PointsPerWavelength;

%%
Acquisition.NumberOfFrames = 1;
Acquisition.PulsingScheme = 'x-AM'; % options: {'x-AM' 'x-Bmode'}
Acquisition.NumberOfShifts = 4;

%%
sequence = {'left', 'right', 'both'};

%% currently only square arrays are supported
Transducer.Type = 'RCA';
Transducer.NumberOfElements = 33 + Acquisition.NumberOfShifts; %4; 
Transducer.NumberOfElementsOrth = Transducer.NumberOfElements;
Transducer.NumberOfActiveElements = 32;
Transducer.Pitch = 100e-6; % [m]
Transducer.ElementWidth = 100e-6; % [m]
Transducer.ElementHeight = Transducer.NumberOfElementsOrth * Transducer.ElementWidth; 
Transducer.ElevationFocus = Inf;
Transducer.BandwidthLow = 14e6; % [Hz]
Transducer.BandwidthHigh = 22e6; % [Hz]
Transducer.SamplingRate = 250e6; % [Hz]
Transducer = estimate_impulse_response(Transducer);

%%
Transmit.NumberOfCycles = 4; 
Transmit.AcousticPressure = 400e3; % [Pa]
Transmit.Envelope = 'Gaussian';
Transmit.SamplingRate = 250e6; % [Hz]
signal = toneBurst(Transmit.SamplingRate, Transmit.CenterFrequency,...
    Transmit.NumberOfCycles, 'Envelope', Transmit.Envelope);
Transmit.PressureSignal = Transmit.AcousticPressure * signal / max(signal); 
Transmit.Angle = 21; % [deg]
Transmit.LateralFocus = Inf; 

%%
% define transducer element delays 
element_index = 0:Transducer.NumberOfActiveElements/2-1;    
element_index = [element_index fliplr(element_index)];
delays.no_gap = Transducer.Pitch * element_index * sind(Transmit.Angle) / Medium.SpeedOfSound;
delays.gap = [delays.no_gap(1:end/2) 0 delays.no_gap(end/2+1:end)];

% define transducer element apodization 
window_half = getWin(Transducer.NumberOfActiveElements/2, 'Tukey', 'Param', 0.2)';
window.no_gap.both = repmat(window_half, 1, 2);
window.no_gap.left = [window_half zeros(1, length(window_half))];
window.no_gap.right = [zeros(1, length(window_half)) window_half];
window.gap.both = [window_half 0 window_half];
window.gap.left = [window_half zeros(1, length(window_half)+1)];
window.gap.right = [zeros(1, length(window_half)+1) window_half];

%%
Geometry.startDepth = 0; % [m]
Geometry.endDepth   = Transducer.NumberOfActiveElements * Transducer.Pitch / 2 * cotd(Transmit.Angle); % [m]
BB.Xmax = Geometry.endDepth; % [m] 
BB.Xmin = Geometry.startDepth; % [m] 
BB.Ymax = Transducer.NumberOfElements * Transducer.Pitch; % [m]
BB.Ymin = 0; 
BB.Zmax = Transducer.ElementHeight; % [m]
BB.Zmin = 0;
Geometry.Rotation = [1 0 0; 0 1 0; 0 0 1];
Geometry.BoundingBox.Center   = [(BB.Xmax + BB.Xmin)/2;... 
                                 (BB.Ymax + BB.Ymin)/2;...
                                 (BB.Zmax + BB.Zmin)/2];                             
Geometry.BoundingBox.Diagonal = [BB.Xmax - BB.Xmin;... 
                                 BB.Ymax - BB.Ymin;...
                                 BB.Zmax - BB.Zmin];
                             
Geometry = compute_simulation_domain(...
    Geometry, Medium, Transducer, Transmit);

%% Save the GUI parameters:
file_path = '/Users/akuliesh1/MIS_opt_fullRT/GUI_output_parameters_RCA';
mkdir(file_path);
% empty the dir from prev runs
delete([file_path '/*'])

save([file_path '/GUI_output_parameters_RCA.mat'],...
        'Microbubble','SimulationParameters', 'Geometry','Transducer',...
        'Acquisition','Medium','Transmit');

Transmit.Delays = zeros(1, Transducer.NumberOfElements);
Transmit.Apodization = zeros(1, Transducer.NumberOfElements);

% GUI parameters with gap
for shift  = 0 : Acquisition.NumberOfShifts
    for i = 1 : length(sequence)
        Transmit.Delays(1+shift:length(delays.gap)+shift) = delays.gap; 
        switch sequence{i}
            case 'left'
                Transmit.Apodization(1+shift:length(window.gap.left)+shift) = window.gap.left;
            case 'right'
                Transmit.Apodization(1+shift:length(window.gap.right)+shift) = window.gap.right;
            case 'both'
                Transmit.Apodization(1+shift:length(window.gap.both)+shift) = window.gap.both;
        end
        save([file_path '/GUI_output_parameters_RCA_' sequence{i} '_gap_' num2str(shift) '.mat'],...
            'Transmit');
    end
end
%%
Transmit.Delays = zeros(1, Transducer.NumberOfElements);
Transmit.Apodization = zeros(1, Transducer.NumberOfElements);

% GUI parameters without gap
for shift  = 0 : Acquisition.NumberOfShifts
    for i = 1 : length(sequence)
        Transmit.Delays(1+shift:length(delays.no_gap)+shift) = delays.no_gap; 
        switch sequence{i}
            case 'left'
                Transmit.Apodization(1+shift:length(window.no_gap.left)+shift) = window.no_gap.left;
            case 'right'
                Transmit.Apodization(1+shift:length(window.no_gap.right)+shift) = window.no_gap.right;
            case 'both'
                Transmit.Apodization(1+shift:length(window.no_gap.both)+shift) = window.no_gap.both;
        end
        save([file_path '/GUI_output_parameters_RCA_' sequence{i} '_no_gap_' num2str(shift) '.mat'],...
            'Transmit');
    end
end

%% put the MB in the center of domain
% point in the center
% points = [(BB.Xmax + BB.Xmin)/2;... 
%          (BB.Ymax + BB.Ymin)/2;...
%          (BB.Zmax + BB.Zmin)/2];
     
points = [1e-3 2e-3 3e-3;... 
         repmat((BB.Ymax + BB.Ymin)/2, 1, 3);...
         repmat((BB.Zmax + BB.Zmin)/2, 1, 3)];
     
file_path = '/Users/akuliesh1/MIS_opt_fullRT/MBframeRCA';
mkdir(file_path);
% empty the dir from prev runs
delete([file_path '/*'])
     
frame = 1; 
Frame.Points = points; 
Frame.Diameter = 1.5e-6 * ones(3, 1); % 1.5e-6 for 15.625 MHz
file_num = num2str(frame/10000,  '%.4f');
save([file_path '/Frame_', file_num(3:end), '.mat'], 'Frame');

%%
% beam_width = 8; % 2 x 400um/100um = 8 elements
% BB_full = BB;
% BB_full.Ymax = (Transducer.NumberOfElements + beam_width) * Transducer.Pitch; % [m]
% 
% point = [(BB_full.Xmax + BB_full.Xmin)/2;... 
%          (BB_full.Ymax + BB_full.Ymin)/2;...
%          (BB_full.Zmax + BB_full.Zmin)/2];  
%      
% file_path = '/Users/akuliesh1/MIS_opt_fullRT/MBframeRCA';
% mkdir(file_path);
%      
% for frame = 1 : beam_width
%     Frame.Points = point - [0; Transducer.Pitch * (frame-1); 0]; 
%     Frame.Diameter = 1.8e-6;
%     file_num = num2str(frame/1000,  '%.3f');
%     save([file_path '/Frame_', file_num(3:end), '.mat'], 'Frame');
% end


