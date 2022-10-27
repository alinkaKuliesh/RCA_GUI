function write_to_file(Microbubble,SimulationParameters,Geometry,...
    Transducer,Acquisition,Medium,Transmit)
% Add the grid size, the element delays, the apodization, and the
% microbubble radii to the GUI output parameters. Update the simulation
% domain. Write all GUI parameters to file.
%
% Voxelization of the transducer results in round-off error in the
% transducer dimensions. The simulation domain and the delays are computed
% with a reshaped transducer that is a rescaled version of the voxelized
% transducer.
%
% Nathan Blanken, University of Twente, 2022

% Compute the grid size:
c    = Medium.SpeedOfSound;
f0   = Transmit.CenterFrequency;
ppwl = SimulationParameters.PointsPerWavelength;

grid_size = c/(f0*ppwl);
SimulationParameters.GridSize = grid_size;

% Voxelize the transducer and scale back to physical dimensions with the 
% grid size:
[TransducerReshaped, Transducer.VoxelTransducer] = ...
    voxelize_transducer(Transducer, grid_size);

% Update the properties of the simulation domain:
Geometry = compute_simulation_domain(...
    Geometry, Medium, TransducerReshaped, Transmit);

% Compute delays
if ~isfield(Transmit,'Delays')
    Transmit = compute_delays(Transmit,TransducerReshaped,Medium);
end

% Assign apodization
if ~isfield(Transmit,'Apodization')
    Transmit.Apodization = ones(1,Transducer.NumberOfElements);
end

% Draw random radii from size distribution:
P = Microbubble.Distribution.Probabilities;
R = Microbubble.Distribution.Radii;
N = Microbubble.Number;

Microbubble.Radii = draw_random_radii(P,R,N);

% Save the GUI parameters:
save('GUI_output_parameters.mat', 'Microbubble','SimulationParameters',...
    'Geometry','Transducer','Acquisition','Medium','Transmit')

end