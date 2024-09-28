function U = compute_utility_v2(R, eta_gains, eta_losses, lambda)
    % Compute utility with separate shape parameters for gains and losses
    
    % Utility computation for gains (R >= 0)
    U_gains = abs(R(R >= 0)).^eta_gains;

    % Utility computation for losses (R < 0)
    U_losses = -lambda * abs(R(R < 0)).^eta_losses;

    % Concatenate the utilities for gains and losses
    U = zeros(size(R));
    U(R >= 0) = U_gains;
    U(R < 0) = U_losses;
end