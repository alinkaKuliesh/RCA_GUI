function Transmit = reset_transmit(Transducer)

Transmit.Type               = 'Three-level';
Transmit.CenterFrequency    = 2.5e6;            % [Hz]
Transmit.NumberOfCycles     = 2;
Transmit.AcousticPressure   = 200e3;            % [Pa]
Transmit.Envelope           = 'Rectangular';
Transmit.SamplingRate       = 250e6;            % [Hz]

Transmit = get_voltage_signal(Transmit);
Transmit = get_pressure_signal(Transmit,Transducer);

Transmit.Advanced           = false;
Transmit.LateralFocus       = Inf;              % [m]
Transmit.Angle              = 0;                % [deg]

Transmit.DelayType          = 'Compute delays';
Transmit.ApodizationType    = 'Uniform apodization';
Transmit.MechanicalIndex    = compute_mechanical_index(Transmit);

end