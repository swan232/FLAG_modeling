function beta = alpha_weights(alpha)
beta = (alpha).^[0 1 2 3 4]; % alpha < 1: primacy, alpha > 1 recency
beta = beta / sum(beta); % normalize weights to take average
