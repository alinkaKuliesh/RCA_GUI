function [TRANS_SURFACE, TRANS_PROJECTION] = ...
    compute_transducer_vertices(Transducer, Transmit, d)
% Compute the vertices of the rectangular surface of a transducer. Also
% compute the vertices of the projection of the transducer surface on a
% parallel surface at a distance d from the transducer.
%
% The projection is defined as the intersection of two projections:
%
% PROJECTION 1: projection of the transducer surface through the elevation
% focus line onto the parallel surface (pinhole projection).
%
% Elevation focus line: x = f_e, z = 0
%
% PROJECTION 2: projection of the transducer surface through the lateral 
% focus line onto the parallel surface (pinhole projection).
%
% Lateral focus line: x = f_x, y = f_y
%
% INPUT:
% - Transducer: struct holding the transducer dimensions and the elevation
%   focus.
% - Transmit: struct holding the lateral focus distance and the transmit
%   angle.
%
% OUTPUT:
% - TRANS_SURFACE: Vertices of the transducer surface (4x3)
% - TRANS_PROJECTION: Vertices of the transducer projection (4x3)
%
% Nathan Blanken, University of Twente, 2022

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRANSDUCER AND BEAM PROPERTIES
p       = Transducer.Pitch;                 % [m]
w       = Transducer.ElementWidth;          % [m]
N       = Transducer.NumberOfElements;
f_e     = Transducer.ElevationFocus;        % [m]
f_l     = Transmit.LateralFocus;            % [m]
if strcmp(Transducer.Type, 'RCA')
    theta = 0;
else
    theta   = Transmit.Angle;               % [deg]
end

% Compute transducer width and height:
W = p*(N-1) + w;                          	% [m]
H = Transducer.ElementHeight;               % [m]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRANSDUCER SURFACE VERTICES
yl	= -W/2;
yr	=  W/2;
zb 	= -H/2;
zt	=  H/2;

Xt = [0 0 0 0];
Yt = [yr yl yl yr];
Zt = [zt zt zb zb];

TRANS_SURFACE = transpose([Xt; Yt; Zt]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROJECTION VERTICES

% PROJECTION 1: projection through the elevation focus line.
zt =  H/2*(1-d/f_e);    % Top line
zb = -H/2*(1-d/f_e);    % Bottom line

% PROJECTION 2: projection through the lateral focus line.
if abs(f_l) < Inf
    % Focused beam:
    
    fx = f_l*cosd(theta);           % Axial focus coordinate
    fy = f_l*sind(theta);           % Lateral focus coordinate

    yl = -W/2*(1-d/fx) + d*fy/fx;   % Left line
    yr =  W/2*(1-d/fx) + d*fy/fx;   % Right line

else
    % Unfocused transducer:
    yl = -W/2 + d*sind(theta);      % Left line
    yr =  W/2 + d*sind(theta);      % Right line

end

% INTERSECTION OF THE TWO PROJECTIONS:
Xp = [d d d d];
Yp = [yr yl yl yr];
Zp = [zt zt zb zb];

TRANS_PROJECTION = transpose([Xp; Yp; Zp]);

end