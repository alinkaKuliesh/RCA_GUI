function MI = compute_mechanical_index(Transmit)

f = Transmit.CenterFrequency/1e6;   % (MHz)
P = Transmit.AcousticPressure/1e6;  % Peak negative pressure (MPa)
MI = P/sqrt(f);                     % Mechanical index

end