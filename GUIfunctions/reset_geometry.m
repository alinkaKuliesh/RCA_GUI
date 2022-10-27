function Geometry = reset_geometry(Geometry)

Geometry.Type = 'RenalTree';

switch Geometry.Type
    case 'RenalTree'
        
        Geometry.STLfile    = 'maa.stl';
        Geometry.STLunit    = 1e-6;         % STL unit length [m]

        % Bounding box of the vessel tree [m]:
        BB = load('renal_tree_bounding_box.mat');
        
        % Rotation matrix for the vessel tree and the microbubbles:
        Geometry.Rotation = [0 0 -1; -1 0 0; 0 1 0];
        
        
        % PROPERTIES FOR VISUALIZATION IN THE GUI:
        
        % Image to show in the main window:
        Geometry.Visualization.Image = 'renal_tree.png';

        % File containing only the vertices of the STL file:
        Geometry.Visualization.VesselVerticesFile = ...
            'renal_tree_vertices.mat';

        % Fraction of vertices to show in plot:
        Geometry.Visualization.Fraction = 1e-2;
        
    case 'MouseBrain'
        
        Geometry.STLfile    = 'vessel.stl';
        Geometry.STLunit    = 1e-6;         % STL unit length [m]

        % Bounding box of the vessel tree [m]:
        BB = load('mouse_brain_bounding_box.mat');
        
        % Rotation matrix for the vessel tree and the microbubbles:
        Geometry.Rotation = [1 0 0; 0 1 0; 0 0 1];
        
        
        % PROPERTIES FOR VISUALIZATION IN THE GUI:
        
        % Image to show in the main window:
        Geometry.Visualization.Image = 'mouse_brain.png';

        % File containing only the vertices of the STL file:
        Geometry.Visualization.VesselVerticesFile = ...
            'mouse_brain_vertices.mat';

        % Fraction of vertices to show in plot:
        Geometry.Visualization.Fraction = 1e-2;
end

Geometry.BoundingBox.Center   = [(BB.Xmax + BB.Xmin)/2;... 
                                 (BB.Ymax + BB.Ymin)/2;...
                                 (BB.Zmax + BB.Zmin)/2];   
                           
Geometry.BoundingBox.Diagonal = [BB.Xmax - BB.Xmin;... 
                                 BB.Ymax - BB.Ymin;...
                                 BB.Zmax - BB.Zmin];

% Depth of vessel tree from transducer surface [m]
Geometry.startDepth  = 25e-3;                    


% PROPERTIES FOR VISUALIZATION IN THE GUI:

% Show the transducer and beam in plot:
Geometry.Visualization.ShowTransducer = 1;
Geometry.Visualization.ShowBeam       = 0;
Geometry.Visualization.ShowDomain     = 1;


end