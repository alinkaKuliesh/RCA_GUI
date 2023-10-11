clear all

%% Define paths
Paths.Path_To_Github_Host = 'C:\Users\bheiles\Documents\Github\'; % Path to the github repos on the host computer (your own)
Paths.Path_To_Github_Remote = './'; % Path to the github repos on the remote server
Paths.Path_To_Save_Params = ['/MIS_opt_fullRT/DATA/PSF_1MB/Simulation_Parameters']; % This is the name of the folder where the parameters of this simulation will be saved
Paths.Path_To_Save_MB = [Paths.Path_To_Save_Params, filesep, 'MBframeRCA']; % This is the name of the folder where the microbubble positions are stored
Paths.Path_To_Save_Results = ['DATA/PSF_1MB/Simulation_Results']; % this is the name of the folder where the simmulation results will be saved on the remote comptuer

%% load standard Microbbuble and Medium GUI parameters
load([Paths.Path_To_Github_Host, filesep, '/RCA_GUI/Standard_MBs_Medium.mat'], 'Microbubble', 'Medium')

%% Load and add kWave paths
addpath(genpath([Paths.Path_To_Github_Host, 'kWave\k-Wave\']));

%%
Transmit.CenterFrequency = 15.625e6; % [Hz]

%%
SimulationParameters.CFL = 0.3; % Courant-Friedrischs-Lewy number, cO dt/dx distance a wave can travel in grid spacing, governs the maximum permissible time step
SimulationParameters.PointsPerWavelength = 8;
SimulationParameters.GridSize = Medium.SpeedOfSound / Transmit.CenterFrequency / ...
    SimulationParameters.PointsPerWavelength;

%%
Acquisition.NumberOfFrames = 1;
Acquisition.PulsingScheme = 'x-AM'; % options: {'x-AM' 'x-Bmode'}
Acquisition.NumberOfShifts = 10; % we will shift/move the elements in one direction in the domain to simulate the probe without simulating all elements

%%
switch Acquisition.PulsingScheme
    case 'x-AM'
        sequence = {'left', 'right', 'both'};
    case 'x-Bmode'
        sequence = {'both'};
end

%% currently only square arrays are supported
Transducer.Type = 'RCA';
Transducer.NumberOfElements = 33 + Acquisition.NumberOfShifts; % Number of elements
Transducer.NumberOfElementsOrth = Transducer.NumberOfElements; % Number of orthogonal elements
Transducer.NumberOfActiveElements = 32;
Transducer.Pitch = 100e-6; % [m]
Transducer.ElementWidth = 100e-6; % [m]
Transducer.ElementHeight = Transducer.NumberOfElementsOrth * Transducer.ElementWidth; % Height is the length of the elements
Transducer.ElevationFocus = Inf; % No elevation focus for RCA
Transducer.BandwidthLow = 14e6; % [Hz]
Transducer.BandwidthHigh = 22e6; % [Hz]
Transducer.SamplingRate = 250e6; % [Hz]
Transducer = estimate_impulse_response(Transducer); % estimate impulse response based on a Butterworth bandpass filter

%%
Transmit.NumberOfCycles = 4; % Number of cycles
Transmit.AcousticPressure = 400e3; % [Pa]
Transmit.Envelope = 'Gaussian';
Transmit.SamplingRate = 250e6; % [Hz]
signal = toneBurst(Transmit.SamplingRate, Transmit.CenterFrequency, ...
    Transmit.NumberOfCycles, 'Envelope', Transmit.Envelope);
Transmit.PressureSignal = Transmit.AcousticPressure * signal / max(signal);
Transmit.Angle = 21; % [deg]
Transmit.LateralFocus = Inf;

%%
% define transducer element delays
element_index = 0:Transducer.NumberOfActiveElements / 2 - 1;
element_index = [element_index fliplr(element_index)];
delays.no_gap = Transducer.Pitch * element_index * sind(Transmit.Angle) / Medium.SpeedOfSound;
delays.gap = [delays.no_gap(1:end / 2) 0 delays.no_gap(end / 2 + 1:end)];

% define transducer element apodization
window_half = getWin(Transducer.NumberOfActiveElements / 2, 'Tukey', 'Param', 0.2)';
window.no_gap.both = repmat(window_half, 1, 2);
window.no_gap.left = [window_half zeros(1, length(window_half))];
window.no_gap.right = [zeros(1, length(window_half)) window_half];
window.gap.both = [window_half 0 window_half];
window.gap.left = [window_half zeros(1, length(window_half) + 1)];
window.gap.right = [zeros(1, length(window_half) + 1) window_half];

%%
Geometry.startDepth = 0; % [m]
Geometry.endDepth = Transducer.NumberOfActiveElements * Transducer.Pitch / 2 * cotd(Transmit.Angle); % [m]
Geometry.endDepth = Transducer.NumberOfActiveElements * Transducer.Pitch / 2 * cotd(21); % [m]
BB.Xmax = Geometry.endDepth; % [m]
BB.Xmin = Geometry.startDepth; % [m]
BB.Ymax = Transducer.NumberOfElements * Transducer.Pitch; % [m]
BB.Ymin = 0;
BB.Zmax = Transducer.ElementHeight; % [m]
BB.Zmin = 0;
Geometry.Rotation = [1 0 0; 0 1 0; 0 0 1];
Geometry.BoundingBox.Center = [(BB.Xmax + BB.Xmin) / 2; ...
                                   (BB.Ymax + BB.Ymin) / 2; ...
                                   (BB.Zmax + BB.Zmin) / 2];
Geometry.BoundingBox.Diagonal = [BB.Xmax - BB.Xmin; ...
                                     BB.Ymax - BB.Ymin; ...
                                     BB.Zmax - BB.Zmin];

Geometry = compute_simulation_domain( ...
    Geometry, Medium, Transducer, Transmit);
%% Create a loop to generate MBS
points = [1e-3 2e-3 3e-3 4e-3; ...
              repmat((BB.Ymax + BB.Ymin) / 2, 1, 4); ...
              repmat((BB.Zmax + BB.Zmin) / 2, 1, 4)];

for i_points = 1:size(points, 2)

    %% Modify paths accordingly
    Paths.Path_To_Save_Params_Loop = [Paths.Path_To_Save_Params, filesep, 'Bubble_', num2str(i_points)];
    Paths.Path_To_Save_MB = [Paths.Path_To_Save_Params_Loop, filesep, 'MBframeRCA']; % This is the name of the folder where the microbubble positions are stored
    Paths.Path_To_Save_Results = [Paths.Path_To_Save_Results, filesep, 'Bubble_', num2str(i_points)]

    mkdir([Paths.Path_To_Github_Host, filesep, Paths.Path_To_Save_MB]);
    % empty the dir from prev runs
    % delete([Path_To_Save_MB '/*'])

    frame = 1;
    Frame.Points = points;
    Frame.Diameter = 1.5e-6 * ones(4, 1); % 1.5e-6 for 15.625 MHz
    file_num = num2str(frame / 10000, '%.4f');
    save([Paths.Path_To_Github_Host, filesep, Paths.Path_To_Save_MB, filesep, 'Bubble_', num2str(i_points), '_Frame_', file_num(3:end), '.mat'], 'Frame');
    %% Save the GUI parameters:
    mkdir([Paths.Path_To_Github_Host, filesep, Paths.Path_To_Save_Params_Loop]);
    % empty the dir from prev runs
    % delete([Paths.Path_To_Save_Params '/*'])

    save([Paths.Path_To_Github_Host, filesep, Paths.Path_To_Save_Params_Loop '/GUI_output_parameters_RCA.mat'], ...
        'Microbubble', 'SimulationParameters', 'Geometry', 'Transducer', ...
        'Acquisition', 'Medium', 'Transmit');

    Transmit.Delays = zeros(1, Transducer.NumberOfElements);
    Transmit.Apodization = zeros(1, Transducer.NumberOfElements);

    % GUI parameters with gap
    for shift = 0:Acquisition.NumberOfShifts

        for i = 1:length(sequence)
            Transmit.Delays(1 + shift:length(delays.gap) + shift) = delays.gap;

            switch sequence{i}
                case 'left'
                    Transmit.Apodization(1 + shift:length(window.gap.left) + shift) = window.gap.left;
                case 'right'
                    Transmit.Apodization(1 + shift:length(window.gap.right) + shift) = window.gap.right;
                case 'both'
                    Transmit.Apodization(1 + shift:length(window.gap.both) + shift) = window.gap.both;
            end

            save([Paths.Path_To_Github_Host, filesep, Paths.Path_To_Save_Params_Loop '/Transmit_sequence_' sequence{i} '_gap_' num2str(shift) '.mat'], ...
            'Transmit');
        end

    end

    %%
    Transmit.Delays = zeros(1, Transducer.NumberOfElements);
    Transmit.Apodization = zeros(1, Transducer.NumberOfElements);

    % GUI parameters without gap
    for shift = 0:Acquisition.NumberOfShifts

        for i = 1:length(sequence)
            Transmit.Delays(1 + shift:length(delays.no_gap) + shift) = delays.no_gap;

            switch sequence{i}
                case 'left'
                    Transmit.Apodization(1 + shift:length(window.no_gap.left) + shift) = window.no_gap.left;
                case 'right'
                    Transmit.Apodization(1 + shift:length(window.no_gap.right) + shift) = window.no_gap.right;
                case 'both'
                    Transmit.Apodization(1 + shift:length(window.no_gap.both) + shift) = window.no_gap.both;
            end

            save([Paths.Path_To_Github_Host, filesep, Paths.Path_To_Save_Params_Loop '/Transmit_sequence_' sequence{i} '_no_gap_' num2str(shift) '.mat'], ...
            'Transmit');
        end

    end

end