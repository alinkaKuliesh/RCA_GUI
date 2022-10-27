function Geometry = compute_simulation_domain(...
    Geometry, Medium, Transducer, Transmit)
% Compute the required simulation domain. The simulation domain should
% capture the beam up to the maximum depth of the vessel tree.

% Rotate the diagonal of the bounding box:
diagVec = Geometry.Rotation*Geometry.BoundingBox.Diagonal;

% Add the depth of the rotated bounding box to the start depth:
startDepth = Geometry.startDepth;
endDepth   = Geometry.startDepth + abs(diagVec(1));

% Compute the vertices of the transducer surface and its projection on the
% back surface of the domain:
[TransducerSurface, TransducerProjection] = ...
    compute_transducer_vertices(Transducer, Transmit, endDepth);
                
V = [TransducerSurface; TransducerProjection];   

% Compute the domain boundary values. Add a margin of two wavelengths:

Domain.Margin = 2*Medium.SpeedOfSound/Transmit.CenterFrequency;

Vmax = max(V) + Domain.Margin;
Vmin = min(V) - Domain.Margin;

Xmax = Vmax(1); Ymax = Vmax(2); Zmax = Vmax(3);
Xmin = Vmin(1); Ymin = Vmin(2); Zmin = Vmin(3);

% Compute the vertices of the domain:
X = [Xmin Xmin Xmin Xmin Xmax Xmax Xmax Xmax];
Y = [Ymax Ymax Ymin Ymin Ymax Ymax Ymin Ymin];
Z = [Zmax Zmin Zmin Zmax Zmax Zmin Zmin Zmax];

% Store the transducer surface vertices, the projection vertices, the
% domain boundary values, and the domain vertices in a struct:

Domain.TransducerSurface     = TransducerSurface;
Domain.TransducerProjection  = TransducerProjection;

Domain.Xmax = Xmax; Domain.Ymax = Ymax; Domain.Zmax = Zmax;
Domain.Xmin = Xmin; Domain.Ymin = Ymin; Domain.Zmin = Zmin;

Domain.Vertices = transpose([X; Y; Z]);

% Add the Domain struct to the Geometry struct:
Geometry.Domain = Domain;

% Compute the centre of the rotated bounding box:
Geometry.Center = [(startDepth + endDepth)/2; 0; 0] ;
end