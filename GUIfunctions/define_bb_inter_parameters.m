% GUI parameters for RCA probe
clear all

load('/Users/akuliesh1/microbubble-flow-simulator-gui/GUI_output_parameters.mat', ...
    'Medium', 'Microbubble', 'Transmit', 'SimulationParameters', 'Acquisition',...
    'Transducer')
%%
Acquisition.NumberOfFrames = 1;
%%
Geometry.startDepth = 0; % [m]
Geometry.endDepth   = 0.025; % [m]
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

%%
wavelength = Medium.SpeedOfSound / Transmit.CenterFrequency;
center = [0.020;... 
       (BB.Ymax + BB.Ymin)/2;...
       (BB.Zmax + BB.Zmin)/2];  

Frame.Diameter(1:2) = 2.14e-6 * 2;
Frame.Diameter = Frame.Diameter.';

frame = 1; 
folderPath = '/Users/akuliesh1/MIS_opt_fullRT';
file_num = num2str(frame/10000,  '%.4f');
distances_in_wavelength = [0.25 0.5 0.75 1 2 3 4 5 10 15 20 25 30];
for i = 1 : length(distances_in_wavelength)
    distance = distances_in_wavelength(i) * wavelength; 
    Frame.Points(1, :) = center - [0; distance/2; 0]; 
    Frame.Points(2, :) = center + [0; distance/2; 0]; 
    folderName = ['MBframe_bb_inter_' num2str(distances_in_wavelength(i))];
    mkdir(folderPath, folderName);
    save([folderPath, '/', folderName, '/Frame_', file_num(3:end), '.mat'], 'Frame');
end
%%
% Save the GUI parameters:
save('/Users/akuliesh1/MIS_opt_fullRT/GUI_output_parameters_bb_inter.mat',...
    'Microbubble','SimulationParameters', 'Geometry','Transducer','Acquisition','Medium','Transmit');


