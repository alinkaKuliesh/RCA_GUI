function distributionValid = check_distribution(Distribution)

% Incomplete check

if isfield (Distribution,'R') && isfield (Distribution,'P')

distributionValid = true;

else
    error('Invalid fields')

end

end