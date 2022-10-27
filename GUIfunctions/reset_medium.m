function Medium = reset_medium()

% Assign the properties of the bulk tissue:
Medium.Tissue = 'General tissue';
Medium.Inhomogeneity = 0.05;               % (standard deviation)
Medium = assign_medium_properties(Medium); 

% Assign the properties of blood:
Vessel.Tissue = 'Blood';
Vessel = assign_medium_properties(Vessel);

% Additional properties of blood for the microbubble module:
Vessel.ThermalConductivity = 0.52;      % [W/m/K] (itis.swiss)
Vessel.SpecificHeat        = 3770;      % [J/kg/K] (Xu et al.)
Vessel.DynamicViscosity    = 4.5e-3;    % [Pa.s] (Nader et al.)
Vessel.SurfaceTension      = 0.053;     % @ 37 deg C [N/m] (Rosina et al.)
Vessel.Temperature         = 310;       % [K] (Reitman)
Vessel.Pressure            = 1.013e5;   % Atmospheric pressure [Pa]

Medium.Vessel = Vessel;

% REFERENCES

% Haim Azhari, “Appendix A: Typical acoustic properties of tissues,” in
% Basics of Biomedical Ultrasound for Engineers, pp. 313–314, John Wiley & 
% Sons, Inc., 2010.

% Nader et al., Front. Physiol., 17 October 2019, Sec. Red Blood Cell 
% Physiology, https://doi.org/10.3389/fphys.2019.01329

% Rosina et al., Physiol. Res. 56 (Suppl. 1): S93-S98, 2007, 
% 10.33549/physiolres.931306

% Xu, F., Lu, T.J. & Seffen, K.A. Biothermomechanical behavior of skin 
% tissue. Acta Mech. Sin. 24, 1–23 (2008). 
% https://doi.org/10.1007/s10409-007-0128-8

% https://itis.swiss/virtual-population/tissue-properties/database/
% thermal-conductivity/

% Reitman, M.L. (2018), Of mice and men – environmental temperature, body 
% temperature, and treatment of obesity. FEBS Lett, 592: 2098-2107. 
% https://doi.org/10.1002/1873-3468.13070

end