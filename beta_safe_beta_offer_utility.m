function p_left = beta_safe_beta_offer_utility(beta_safe, beta_offer, delta)
beta_side = 0;
epsilon_left = 0;
epsilon_right = 0;
S = 1; % deck left, p_left is also p_deck
DV = beta_side + ( beta_safe - beta_offer * delta) .* S; 
% probability of chosing left
p_left = (1-epsilon_left-epsilon_right) ./ ( 1 + exp(DV) ) + epsilon_left;