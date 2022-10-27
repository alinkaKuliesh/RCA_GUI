function SimulationParameters = update_simulation_parameters(...
    SimulationParameters, f0)
% SimulationParameters: struct with simulation parameters
% f0: transmit frequency

CFL     = SimulationParameters.CFL;     % Courant-FriedrichsLewy number
ppwl	= SimulationParameters.PointsPerWavelength;
in_var  = SimulationParameters.IndependentVariable;
fs      = SimulationParameters.SamplingRate;

switch in_var
    case 'CFL'
        SimulationParameters.SamplingRate = f0*ppwl/CFL;
        
    case 'Sampling rate'
        SimulationParameters.CFL = f0*ppwl/fs;
end


end