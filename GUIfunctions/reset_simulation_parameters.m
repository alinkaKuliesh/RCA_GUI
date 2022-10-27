function SimulationParameters = reset_simulation_parameters(f0)
% Simulation parameters depend on the transmit frequency f0 (Hz).

CFL = 0.3; % Courant-FriedrichsLewy number
ppwl = 8;  % Points per wavelength

SimulationParameters.IndependentVariable    = 'CFL';
SimulationParameters.CFL                    = CFL;
SimulationParameters.SamplingRate           = f0*ppwl/CFL;   % (Hz)
SimulationParameters.PointsPerWavelength    = ppwl;


end