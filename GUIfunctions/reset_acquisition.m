function Acquisition = reset_acquisition()

Acquisition.FrameRate = 500;            % (Hz)
Acquisition.NumberOfFrames = 50;    
Acquisition.PulsingScheme = 'Standard';
Acquisition.TimeBetweenPulses = 100e-6; % (s);

end