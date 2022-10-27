function [TransReshaped, VoxelTrans] = ...
    voxelize_transducer(Transducer, grid_size)
% 1. Put the transducer elements on a grid and express the dimensions in
%    number of grid points.
% 2. Scale the voxelized transducer by the grid size.

% VOXELIZE THE TRANSDUCER
% Express the transducer geometry in number of grid points.

VoxelTrans.num_elements     = Transducer.NumberOfElements;
VoxelTrans.num_elements_orth = Transducer.NumberOfElementsOrth;

kerf                        = Transducer.Pitch ...
                              - Transducer.ElementWidth; % [m]
VoxelTrans.kerf             = floor(kerf/grid_size);   

VoxelTrans.pitch            = round(Transducer.Pitch/grid_size);
VoxelTrans.element_width    = VoxelTrans.pitch - VoxelTrans.kerf;

% VoxelTrans.element_length   = round(Transducer.ElementHeight/grid_size);
VoxelTrans.element_length   = Transducer.NumberOfElementsOrth * VoxelTrans.element_width; 

VoxelTrans.elevation_focus  = Transducer.ElevationFocus; % [m]

N                           = VoxelTrans.num_elements;
VoxelTrans.size_y           = VoxelTrans.element_width*N + ...
                              VoxelTrans.kerf*(N - 1);

% SCALE THE TRANSDUCER BACK TO PHYSICAL DIMENSIONS
TransReshaped = Transducer;

TransReshaped.Pitch            = grid_size*VoxelTrans.pitch;
TransReshaped.ElementWidth     = grid_size*VoxelTrans.element_width;
TransReshaped.ElementHeight    = grid_size*VoxelTrans.element_length;

end