function [alpha, beta, resnorm, residual] = fit_sigmoid_function_choice_curve(sub_i, if_plot)

R = [sub_i.game.rewards];
O = [sub_i.game.offer];
C = [sub_i.game.choseDeck];

% difference between mean reward and offer
decisionValues = mean(R, 'omitmissing') - O; 
choices = C;

% remove NaN
decisionValues = decisionValues(~isnan(decisionValues));
choices = double(choices(~isnan(choices))); % choseDeck need to be double

% Assuming you have mean(R) - O as decision values in 'decisionValues' 
% and corresponding choices in 'choices'

% Define the sigmoid function
sigmoid = @(params, x) 1 ./ (1 + exp(-(params(1) + params(2) * x)));

% Initial guess for parameters
initialParams = [0, 1];

% Set up options structure
options = optimoptions('lsqcurvefit', 'Display', 'off');

% Fit the sigmoid function to the data using 'lsqcurvefit'
[fitParams, resnorm, residual, ~, ~] = lsqcurvefit(sigmoid, initialParams, decisionValues, choices,[],[], options);
alpha = fitParams(1); % bias: the point where the curve transitions from one choice to the other. 
beta = fitParams(2); % sensitivity:  the slope or steepness of the sigmoid curve. 
% A larger beta value indicates a steeper curve, meaning that small changes in the decision values result in more significant changes in the predicted choices.

if if_plot
    figure;
    subplot(1,2,1)
    % Plot the data and the fitted sigmoid function
    xValues = linspace(min(decisionValues), max(decisionValues), 100);
    yFit = sigmoid(fitParams, xValues);
    
    
    scatter(decisionValues, choices, 'b'); % Assuming 'choices' are binary (0 or 1)
    hold on;
    plot(xValues, yFit, 'r');
    title('Sigmoid Fit to Data');
    xlabel('Decision Values (mean(R) - O)');
    ylabel('Choose Deck');
    legend('Data', 'Fitted Sigmoid');
    
    % Plot residuals against decision values
    hold on;
    subplot(1,2,2)
    
    % Assuming fitParams contains the estimated parameters from lsqcurvefit
    % Calculate predicted choices using the fitted sigmoid function
    predictedChoices = sigmoid(fitParams, decisionValues);
    
    % Calculate residuals
    residuals = choices - predictedChoices;
    
    scatter(decisionValues, residuals);
    xlabel('Decision Values');
    ylabel('Residuals');
    title('Residuals vs Decision Values');
    hold off;



end

end
