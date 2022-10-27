function Transmit = get_voltage_signal(Transmit)
% Get the voltage signal driving the transducer.

switch Transmit.Type
    case 'Three-level'
        Transmit.VoltageSignal = get_tri_level_signal(Transmit);
    case 'Cosine envelope'
        switch Transmit.Envelope
            case 'Rectangular'
                phi = -pi/2;
                Transmit.VoltageSignal = get_rect_pulse(Transmit,phi);
            case 'Hann'
                phi = -pi/2;
                Transmit.VoltageSignal = get_hann_pulse(Transmit,phi);
        end
end
end
