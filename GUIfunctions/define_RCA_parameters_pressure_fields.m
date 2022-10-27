% Due to the fact the GUI currently doesn't support the RCA probe and
% arbitrary position of MBs (sensors in this situation), this is done
% within this script. 
clear all
%% 
Medium.SpeedOfSound = 1540; % [m/s]
Medium.Density = 1000; % [kg/m^3]
Medium.Inhomogeneity = 0;
Medium.BonA = 6;
Medium.AttenuationA = 0.75; % [dB/cm/MHz^y]
Medium.AttenuationB = 1.5; % power coefficient y

%%
Transmit.CenterFrequency = 15e6; % [Hz]

%%
SimulationParameters.CFL = 0.3;
SimulationParameters.PointsPerWavelength = 8;
SimulationParameters.GridSize = Medium.SpeedOfSound / Transmit.CenterFrequency /...
    SimulationParameters.PointsPerWavelength;

%%
Acquisition.NumberOfFrames = 1;

%%
Transducer.Type = 'RCA';
Transducer.NumberOfElements = 32; 
Transducer.NumberOfElementsOrth = 32;
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
Transmit.NumberOfCycles = 3; 
Transmit.AcousticPressure = 400e3; % [Pa]
Transmit.Envelope = 'Gaussian';
Transmit.SamplingRate = 250e6; % [Hz]
signal = toneBurst(Transmit.SamplingRate, Transmit.CenterFrequency,...
    Transmit.NumberOfCycles, 'Envelope', Transmit.Envelope);
Transmit.PressureSignal = Transmit.AcousticPressure * signal / max(signal); 
Transmit.Angle = 21; % [deg]
Transmit.LateralFocus = Inf; 
% define transducer element delays 
element_index = 0:Transducer.NumberOfActiveElements/2-1;    
element_index = [element_index fliplr(element_index)];
delays.no_gap = Transducer.Pitch * element_index * sind(Transmit.Angle) / Medium.SpeedOfSound;
% define transducer element apodization 
window_half = getWin(Transducer.NumberOfActiveElements/2, 'Tukey', 'Param', 0.2, 'Plot', false)';
window.no_gap.both = repmat(window_half, 1, 2);
window.no_gap.left = [window_half zeros(1, length(window_half))];
window.no_gap.right = [zeros(1, length(window_half)) window_half];

%% interested in the field in front of probe till wave cross-propagate
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

Transmit.Delays = zeros(1, Transducer.NumberOfElements);
Transmit.Apodization = zeros(1, Transducer.NumberOfElements);
sequence = {'both', 'left', 'right'};

% GUI parameters without gap
for i = 1 : length(sequence)
    Transmit.Delays(1:length(delays.no_gap)) = delays.no_gap; 
    switch sequence{i}
        case 'left'
            Transmit.Apodization(1:length(window.no_gap.left)) = window.no_gap.left;
        case 'right'
            Transmit.Apodization(1:length(window.no_gap.right)) = window.no_gap.right;
        case 'both'
            Transmit.Apodization(1:length(window.no_gap.both)) = window.no_gap.both;
    end
    save([file_path '/GUI_output_parameters_RCA_' sequence{i} '.mat'],...
        'SimulationParameters', 'Geometry','Transducer','Acquisition','Medium','Transmit');
end
%% sensor distribution for sound sheet; orientation XZ
orientation = 'xz';

plot_sensor_planes = false;

sensor_points.x = [BB.Xmin : SimulationParameters.GridSize : BB.Xmax];
sensor_points.y = (BB.Ymax + BB.Ymin) / 2;
sensor_points.z = [BB.Zmin : SimulationParameters.GridSize : BB.Zmax];
[X,Z] = meshgrid(sensor_points.x,  sensor_points.z);
X = reshape(X, [], 1);
Z = reshape(Z, [], 1);
Y = sensor_points.y * ones(size(X)); 

points(:, 1) = X;
points(:, 2) = Y;
points(:, 3) = Z;

if plot_sensor_planes
    figure()
    scatter3(X*1e3,Y*1e3,Z*1e3);
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
end

file_path = ['/Users/akuliesh1/MIS_opt_fullRT/MBframeRCA_' orientation];
mkdir(file_path);
% empty the dir from prev runs
delete([file_path '/*'])
     
frame = 1; 
Frame.Points = points; 
file_num = num2str(frame/10000,  '%.4f');
save([file_path '/Frame_', file_num(3:end), '.mat'], 'Frame');

%% sensor distribution for sound sheet; orientation XY
orientation = 'xy';

sensor_points.x = [BB.Xmin : SimulationParameters.GridSize : BB.Xmax];
sensor_points.z = (BB.Zmax + BB.Zmin) / 2;
sensor_points.y = [BB.Ymin : SimulationParameters.GridSize : BB.Ymax];
[X,Y] = meshgrid(sensor_points.x,  sensor_points.y);
X = reshape(X, [], 1);
Y = reshape(Y, [], 1);
Z = sensor_points.z * ones(size(X)); 

points(:, 1) = X;
points(:, 2) = Y;
points(:, 3) = Z;

if plot_sensor_planes
    figure()
    scatter3(X*1e3,Y*1e3,Z*1e3);
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
end

file_path = ['/Users/akuliesh1/MIS_opt_fullRT/MBframeRCA_' orientation];
mkdir(file_path);
% empty the dir from prev runs
delete([file_path '/*'])
     
frame = 1; 
Frame.Points = points; 
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
%%

