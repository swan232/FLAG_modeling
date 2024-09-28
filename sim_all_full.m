% function [Xsim, sim] = sim_all_full(sub, Xfit)
function [Xsim, sim] = sim_all_full(sub, Xfit, model_name) 
% Set the random seed for reproducibility
rng(12345);  % You can use any integer value as a seed

sim = sub; % base simulated subjects on real subjects
Xsim = Xfit;

for sn = 1:length(sim)
    if strcmp(model_name, 'free_curvatures') 
        disp('simulating free curvatures model')
        sim(sn) = sim_EURLfull_v8_freecurvatures(sim(sn), Xsim(:,sn), false);

    elseif strcmp(model_name, 'free_curvatures_free_weights')
        disp('simulating free curvatures free weights model')
        sim(sn) = sim_EURLfull_v8_freecurvatures(sim(sn), Xsim(:,sn), true);
    end
end


