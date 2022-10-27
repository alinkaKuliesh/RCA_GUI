function V = get_tri_level_signal(Transmit)
% Get a pulse train of alternating positive and negative block 
% pulses, with Ncy cycles and frequency f at sampling rate Fs.

Fs = Transmit.SamplingRate;         % [Hz]
f = Transmit.CenterFrequency;       % Centre frequency(Hz)
Ncy = Transmit.NumberOfCycles;      % Number of cycles

ON_Frac = 0.67;                 % Fraction of half cycle with high level

N = round(Fs/f*Ncy);            % Total signal length

% A sine wave is ON_frac of a half cycle above V_th:
V = sin(2*pi*f*(0:(N-1))/Fs);  
V_th = sin((1-ON_Frac)*pi/2);

% Convert sine wave to tri-level signal.
V(V>=V_th)       = 1;
V(V<=-V_th)      = -1;
V(abs(V)<V_th) = 0;

end