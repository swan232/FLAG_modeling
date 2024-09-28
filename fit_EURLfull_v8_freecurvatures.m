function [Xfit_best, nLL_best, XFIT_BEST_STORE, NLL_BEST_STORE, n_improved] = fit_EURLfull_v8_freecurvatures(sub, nReps, free_weights)
rng(12345); % Set the seed to any integer for reproducibility

% fix eta and add eta_gains and eta_losses at the end to allow separate
% curvature shapes for gains and losses

%      eta | lambda | alpha | beta_side | beta_safe | beta_offer | beta_deck | epsilon_left | epsilon_right
X0 = [   1      1      1          0           0           0            0             0              0      ];
LB = [   -10      0     10^-2    -inf        -inf          -1           -1             0              0      ];
UB = [  10     10     10^2      inf         inf           1            1             0              0      ];


% fix eta
LB(1) = 1;
UB(1) = 1;

% fix lambda;
LB(2) = 1;
UB(2) = 1;

% curvatures for gains aand losses
X0 = [X0 1 1];
LB = [LB 0 0];
UB = [UB 10 10];


if free_weights
    % fix alpha
    LB(3) = 1;
    UB(3) = 1;
    % add 4 free betas
    X0 = [X0 .2 .2 .2 .2];
    LB = [LB 10^-2 10^-2 10^-2 10^-2];
    UB = [UB 1 1 1 1];
end

nparam = length(X0);

if free_weights
    model_name = 'free_curvatures_free_weights';
else
    model_name = 'free_curvatures';
end

disp(['Fitting ' model_name ' model to ' num2str(length(sub)) ' subjects'])

X0 = repmat(X0', [1 length(sub)]);
% initialize Xfit to initial conditions
Xfit_best = X0;
% initialize nLL to inf (bad fit!)
nLL_best = Inf(1, length(sub)); 

options = optimoptions('fmincon', 'display', 'off');

% preallocate Xfit and nLL before running fmincon
Xfit = nan(nparam, length(sub));
nLL = inf(1, length(sub));

% loop over repeats
for count = 1:nReps

    % set initial conditions as scrambled Xfit
    for i = 1:size(Xfit_best, 1)
        r = randperm(length(sub));
        X0(i,:) = Xfit_best(i,r);
    end

    % loop over subjects
    parfor sn = 1:length(sub)
        
        % obFunc = @(x) lik_EURLfull_v1_separate_eta(sub(sn), [x(1) x(2) x(3) x(4) x(5) x(6) x(6) x(8) x(9) x(10) x(11)]); 
        if free_weights 
            obFunc = @(x) lik_EURLfull_v8_freecurvatures(sub(sn), [x(1) x(2) x(3) x(4) x(5) x(6) x(6) x(8) x(9) x(10) x(11) x(12) x(13) x(14) x(15)], true); 
        else
            obFunc = @(x) lik_EURLfull_v8_freecurvatures(sub(sn), [x(1) x(2) x(3) x(4) x(5) x(6) x(6) x(8) x(9) x(10) x(11)], false); 
        end

        try
            [Xfit(:,sn), nLL(sn)] = fmincon(obFunc, X0(:,sn), [],[],[],[], LB, UB, [], options);
        catch
            % fit failed
            disp(['   **** fit failed for subject ' num2str(sn) ' ****'])
            Xfit(:,sn) = nan;
            nLL(sn) = inf;
        end

        
        
    end
    
    % find subjects where nLL is lower than previous best
    ind = nLL < nLL_best;
    
    % update new best fit parameters
    disp(['   on iteration : ' num2str(count) ', ' num2str(sum(ind)) ' subjects improved the fit' ])
    Xfit_best(:, ind) = Xfit(:, ind);
    nLL_best(ind) = nLL(ind);
    

    NLL_BEST_STORE(:,count) = nLL_best;
    XFIT_BEST_STORE(:,:,count) = Xfit_best;
    n_improved(count) = sum(ind);
end