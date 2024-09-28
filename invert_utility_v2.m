function R = invert_utility_v2(U, eta_gains, eta_losses, lambda)
% compute inverse utility with separate shape parameters for gains and
% losses

% compute inverse utility for gains (U >= 0)
R_gains = U(U>=0) .^(1/eta_gains);

% compute inverse utility for losses (U < 0)
R_losses = -lambda * abs(U(U < 0)/lambda).^(1/eta_losses);

% Concatenate the inverse utilities for gains and losses
R = zeros(size(U));
R(U >= 0) = R_gains;
R(U < 0) = R_losses;

end


