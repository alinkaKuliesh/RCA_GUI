function V = get_hann_pulse(Transmit,phi)
% Get an Ncy-cycle pulse with a Hann window.

Fs = Transmit.SamplingRate;         % Sampling rate [Hz]
f = Transmit.CenterFrequency;       % Centre frequency(Hz)
Ncy = Transmit.NumberOfCycles;      % Number of cycles
N = round(Ncy*Fs/f);                % Total number of samples
t = (0:(N-1))/Fs;                   % Time vector (s)

% Compute the signal:
V = cos(2*pi*f*t + phi).*sin(2*pi*f*t/Ncy/2).^2;

end