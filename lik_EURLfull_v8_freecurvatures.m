function nLL = lik_EURLfull_v8_freecurvatures(sub, X, free_weights)

%     \item[$\eta$] curvature of utility function
%     \item[$\lambda$] loss aversion
%     \item[$\alpha$] primacy-recency 
%     \item[$\beta_{side}$] side bias
%     \item[$\beta_{safe}$] offer bias
%     \item[$\beta_{offer}$] offer weight
%     \item[$\beta_{deck}$] deck weight
%     \item[$\epsilon_{left}$] left lapse rate
%     \item[$\epsilon_{right}$] right lapse rate

% unpack parameters
eta             = X(1); % curvature of utility function
lambda          = X(2); % loss aversion
alpha           = X(3); % primacy-recency bias
beta_side       = X(4); % side bias
beta_safe       = X(5); % offer bias
beta_offer      = X(6); % offer weight
beta_deck       = X(7); % deck weight
epsilon_left    = X(8); % left lapse rate
epsilon_right   = X(9); % right lapse rate
eta_gains = X(10); % curvature of utility function for gains
eta_losses = X(11); % curvature of utility function for losses

if free_weights 
    beta_r1      = X(12); % weight for first draw
    beta_r2      = X(13); % weight for second draw
    beta_r3      = X(14); % weight for third draw
    beta_r4      = X(15); % weight for fourth draw
    beta_r5      = 1 - sum([beta_r1 beta_r2 beta_r3 beta_r4]); % weights need to add up to 1
end


% unpack data
R = [sub.game.rewards]; % 5 x 100 matrix
O = [sub.game.offer];
C = [sub.game.choseLeft];
S = [sub.game.side];

% out = [sub.game.outlier];

% \item[Step 1] Transform reward values into utilities.
Ur = compute_utility_v2(R, eta_gains, eta_losses, lambda); % R is a matrix, eta_gains and eta_losses are both scala

% \item[Step 2] Combine the rewards to form an average utility for the
% deck. Wi
beta = (alpha).^[0 1 2 3 4]; % primacy-recency
beta = beta / sum(beta); % normalize weights to take average
if free_weights
    beta = [beta_r1 beta_r2 beta_r3 beta_r4 beta_r5];
end


% \item[Step 3] Inverse utility computation to get effective value of deck.
%R deck
Rr = invert_utility_v2(beta*Ur, eta_gains, eta_losses, lambda);

% \item[Step 4] Compare the effective value  of the deck and the offer to make a choice.
% decision variable for softmax
DV = beta_side + ( beta_safe + beta_offer * O - beta_deck * Rr ) .* S;
% probability of chosing left
p_left = (1-epsilon_left-epsilon_right) ./ ( 1 + exp(DV) ) + epsilon_left;
% likelihood of each trial
CP = p_left.*C + (1-p_left).*(1-C);

% compute nLL
nLL = -sum(log(CP));
