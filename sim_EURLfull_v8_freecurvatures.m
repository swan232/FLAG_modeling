function sub = sim_EURLfull_v8_freecurvatures(sub, X, free_weights)
% Set the random seed for reproducibility
rng(12345);  % You can use any integer value as a seed


% unpack parameters
eta             = X(1); % curvature of utility function
lambda          = X(2); % loss aversion
alpha           = X(3); % primacy-recency bias
beta_side       = X(4); % side bias
beta_safe       = X(5); % offer bias
beta_offer      = X(6); % offer weight
beta_deck       = X(6); % deck weight
epsilon_left    = X(8); % left lapse rate
epsilon_right   = X(9); % right lapse rate
eta_gains = X(10); % curvature for gains
eta_losses = X(11); % curvature for losses

if free_weights
    beta_r1      = X(12); % weight for first draw
    beta_r2      = X(13); % weight for second draw
    beta_r3      = X(14); % weight for third draw
    beta_r4      = X(15); % weight for fourth draw
    beta_r5      = 1 - sum([beta_r1 beta_r2 beta_r3 beta_r4]); % weights need to add up to 1
end



% unpack data
R = [sub.game.rewards];
O = [sub.game.offer];
S = [sub.game.side];


% \item[Step 1] Transform reward values into utilities.
Ur = compute_utility_v2(R, eta_gains, eta_losses, lambda);

% \item[Step 2] Combine the rewards to form an average utility for the deck.
beta = (alpha).^[0 1 2 3 4]; % primacy-recency
beta = beta / sum(beta); % normalize weights to take average
if free_weights
    beta = [beta_r1 beta_r2 beta_r3 beta_r4 beta_r5];
end

% \item[Step 3] Inverse utility computation to get effective value of deck.
Rr = invert_utility_v2(beta*Ur, eta_gains, eta_losses, lambda);

% \item[Step 4] Compare the effective value  of the deck and the offer to make a choice.
% decision variable for softmax
DV = beta_side + ( beta_safe + beta_offer * O - beta_deck * Rr ) .* S;
% probability of chosing left
p_left = (1-epsilon_left-epsilon_right) ./ ( 1 + exp(DV) ) + epsilon_left;


% make the choice
C = rand(size(p_left)) < p_left;

for g = 1:length(sub.game)
    sub.game(g).choseLeft = C(g);
    sub.game(g).choseDeck = C(g) == (1+sub.game(g).side)/2;
    sub.game(g).pLeft = p_left(g);
    if (sub.game(g).side==1)
        sub.game(g).pDeck = p_left(g);
    else
        sub.game(g).pDeck = 1-p_left(g);
    end
end
