function ProcessedVertices = process_vertices(Geometry, Vertices)
% Performing the following operations on a point cloud (vertices):
% - Scaling to millimeters
% - Make the point cloud less dense (sparsify)
% - Centre the point cloud
% - Rotate the point cloud
% - Translate the point cloud

% Convert the vertices to millimeters:
X = Vertices(1,:)*Geometry.STLunit*1e3; % [mm]
Y = Vertices(2,:)*Geometry.STLunit*1e3; % [mm]
Z = Vertices(3,:)*Geometry.STLunit*1e3; % [mm]

% Make point cloud less dense for visualization speed:
fraction = Geometry.Visualization.Fraction;
[X,Y,Z] = sparsify(X,Y,Z,fraction);

% Collect vertices as columns in matrix:
Vertices = [X; Y; Z];

% Centre point cloud:
Vertices = Vertices - Geometry.BoundingBox.Center*1e3; % [mm]

% Rotate the point cloud:
Vertices = Geometry.Rotation*Vertices;

% Translate the point cloud to the desired location:
ProcessedVertices = Vertices + Geometry.Center*1e3 ;

end