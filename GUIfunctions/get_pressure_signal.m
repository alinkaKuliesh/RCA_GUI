function Transmit = get_pressure_signal(Transmit,Transducer)

V  = Transmit.VoltageSignal;
IR = Transducer.TransmitImpulseResponse;

% Convolve driving voltage signal with transmit impulse response:
p = conv(V, IR);

% Scale to desired peak negative pressure:
pnp = abs(min(p));
Transmit.PressureSignal = p/pnp*Transmit.AcousticPressure;

end