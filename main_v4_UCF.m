function main_v4_UCF(sub, data_name, n, model_name, fun_names, varargin)

% a master function to apply computational modeling steps
% n: the number of subjects to include (set n to small value for testing)
% (functions) to a given dataset (data_name) with a specific model
% specification (model_name)
% fun_names:    
%   fit model, 
%   plot histogram, 
%   simulation, 
%   parameter recovery
%   plot observed and simulated average choice curve

v_names = {'curvature'
    'loss aversion'
    'primacy-recency'
    'side bias'
    'safe bias'
    'inverse temperature' 
    'deck weight'
    };
v_symbol = {
    '\eta'
    '\lambda'
    '\alpha'
    '\beta_{side}'
    '\beta_{safe}'
    '\beta_{r}'
    '\beta_{deck}'
    '\epsilon_{left}'
    '\epsilon_{right}'};



% free curvatures v_names and v_symbols
if strcmp(model_name, 'free_curvatures')
   % v_symbol =  [v_symbol(3:6);{'\eta_{gains}', '\eta_{losses}'}'];
   v_symbol =  [v_symbol(3:6);{'\eta_{+}', '\eta_{-}'}'];
   v_names = [v_names(3:6); {'curvature for gains', 'curvature for losses'}'];
% free curvatures free weights 
elseif strcmp(model_name, 'free_curvatures_free_weights')
    % v_symbol =  [v_symbol(4:6);{'\eta_{gains}', '\eta_{losses}'}'; {'\beta_{r1}', '\beta_{r2}','\beta_{r3}','\beta_{r4}','\beta_{r5}'}'];
    v_symbol =  [v_symbol(4:6);{'\eta_{+}', '\eta_{-}'}'; {'\beta_{r1}', '\beta_{r2}','\beta_{r3}','\beta_{r4}','\beta_{r5}'}'];
    
    v_names = [v_names(4:6); {'curvature for gains', 'curvature for losses'}';{'reward1 weight', 'reward2 weight', 'reward3 weight', 'reward4 weight', 'reward5 weight'}'];

end

%% Define data set
% filter a subset of the data set for testing
sub = sub(1:n);
disp(['We run computational modeling analysis with the first ' num2str(n) ' subject.' ])

% create subfolder to store outputs 
dataset_output_path = [pwd '/' data_name]; % path to the outputs for a data set
mkdir(dataset_output_path);


%% Given function names, select the functions corresponding to model type
% functions for model fitting
if strcmp(model_name, 'free_curvatures')
    fitFun = @(x) fit_EURLfull_v8_freecurvatures(x, 2, false);
            
elseif strcmp(model_name, 'free_curvatures_free_weights')
    fitFun = @(x) fit_EURLfull_v8_freecurvatures(x, 2, true);

end

% function to plot choice curve
 
choiceCurveFun = @(x) plot_choiceCurves_v2(sub, ... 
    data_name, model_name, ...
    dataset_output_path, ... 
    1, x); % x: sim (simulated data based on a specific model)
    

% function to plot histograms
histFun = @(x, y, z) plot_histograms_Xfit_v2(x, ...% x: fit values
    v_symbol, v_names, ...
    y,... % name of the dataset
    z, ...% name of the model
    true, ... % whether outlier fit values are removed
    dataset_output_path);

% function to simulate data
% x: sub; y: Xfit; outputs: [Xsim, sim] ; z: model_name
simFun = @(x, y, z) sim_all_full(x, y, z); 

% function to refit sim data
if strcmp(model_name, 'free_curvatures')
    recoveryFun = @(x) fit_EURLfull_v8_freecurvatures(x, 2, false);
elseif strcmp(model_name, 'free_curvatures_free_weights')
    recoveryFun = @(x) fit_EURLfull_v8_freecurvatures(x, 2, true);
end

% function to plot parameter recovery
plotRecoveryFun = @(x, y) plot_para_recovery_v2(x,... % first output of sim_all_full()
                                               size(x, 2),... 
                                               y, ...% output of recoveryFun
                                               v_symbol, v_names, ...% global variables of parameter names
                                               data_name, model_name, ...% name of the model
                                               true, ...% whether outlier fit values are removed
                                               dataset_output_path);



% function to describe fit values
describeXfitFun = @(x,y) describe_model_parameter(x,y, v_symbol, v_names, data_name, model_name, true, dataset_output_path);

%% apply the function to specified data set using specified model

% access optional arguments
if nargin > 5
    constraint_param = varargin{1};
end

if strcmp(model_name,'free_curvatures')
    
    if contains('fit', fun_names)
        [Xfit, nLL_best] = check_Xfit();
        % Xfit_path = [dataset_output_path '/' data_name '_' model_name '_Xfit'];
        % [Xfit, nLL_best, ~, ~, ~]  = fitFun(sub);
    end
    
    if contains('sim', fun_names)
        % check_Xfit();
        if (exist('constraint_param','var') == 1)
            [Xfit, nLL_best] = check_Xfit(constraint_param);
        else
            [Xfit, nLL_best] = check_Xfit();
        end
        
        % path to save output of simFun()
        sim_path = [dataset_output_path '/' data_name '_' model_name '_sim'];
        [Xsim, sim] = simFun(sub, Xfit, model_name);
        save([sim_path '.mat'], 'Xsim', 'sim')
    
    end
    
    if any(contains(fun_names, 'choice' ))
        if any(contains(fun_names, 'sim'))
            % make sure sim_full is available
            sim_full_path = [dataset_output_path '/' data_name '_' 'full' '_sim']; % path to 
            if isfile([sim_full_path '.mat'])
                sim_full_output = load([sim_full_path '.mat'], 'sim');
                % Access the loaded data
                sim_full = sim_full_output.sim;
            % sim_full is not available, create it
            else
                [Xfit_full, nLL_best_full, ~, ~, ~]  = fitFun(sub);
                [~, sim_full] = simFun(sub, Xfit_full, model_name);
            end
            
            % choice curves: simulation + observation
            choiceCurveFun(sim)
        else 
            disp('No sim data, cannot plot choice curve as requested')
        end
        
    end

elseif strcmp(model_name,'free_curvatures_free_weights')
    if contains('fit', fun_names)
        [Xfit, nLL_best] = check_Xfit();
        Xfit_path = [dataset_output_path '/' data_name '_' model_name '_Xfit'];
        % [Xfit, nLL_best, ~, ~, ~]  = fitFun(sub);
        
    end
    
    % shared functions between full and nested models
    if contains('sim', fun_names)
        if (exist('constraint_param','var') == 1)
            [Xfit, nLL_best] = check_Xfit(constraint_param);
        else
            [Xfit, nLL_best] = check_Xfit();
        end
        
        % path to save output of simFun()
        sim_path = [dataset_output_path '/' data_name '_' model_name '_sim'];
        [Xsim, sim] = simFun(sub, Xfit, model_name);
        save([sim_path '.mat'], 'Xsim', 'sim')
    
    end
    
    if any(contains(fun_names, 'choice' ))
        if any(contains(fun_names, 'sim'))
            % make sure sim_full is available
            sim_full_path = [dataset_output_path '/' data_name '_' 'full' '_sim']; % path to 
            if isfile([sim_full_path '.mat'])
                sim_full_output = load([sim_full_path '.mat'], 'sim');
                % Access the loaded data
                sim_full = sim_full_output.sim;
            % sim_full is not available, create it
            else
                [Xfit_full, nLL_best_full, ~, ~, ~]  = fitFun(sub);
                [~, sim_full] = simFun(sub, Xfit_full, model_name);
            end
            
            choiceCurveFun(sim);
        else 
            disp('No sim data, cannot plot choice curve as requested')
        end
        
    end
    

end

% shared functions between full and nested models
if any(contains(fun_names, 'histogram'))
    
        if (exist('constraint_param','var') == 1)
            [Xfit, nLL_best] = check_Xfit(constraint_param);
        else
            [Xfit, nLL_best] = check_Xfit();
        end
        disp(model_name)
        
        if strcmp(model_name, 'free_curvatures')
            disp('Plot free curvatures histogram')
            histFun(Xfit([3:6,10:11],:), data_name, model_name)
        elseif strcmp(model_name, 'free_curvatures_free_weights')
            disp('Plot free curvatures free weights histogram')
            histFun(Xfit([4:6,10:15],:), data_name, model_name)
        end


end

if any(contains(fun_names, 'describeXfit'))
    if (exist('constraint_param','var') == 1)
        [Xfit, nLL_best] = check_Xfit(constraint_param);
    else
        [Xfit, nLL_best] = check_Xfit();
    end


    if strcmp(model_name, 'free_curvatures')
        describeXfitFun(sub, Xfit([3:6,10:11],:))
        % Xfit
        % 3 'primacy-recency'
        % 4 'side bias'
        % 5 'safe bias'
        % 6 'inverse temperature' 
        % 10 'curvature for gains'
        % 11 'curvature for losses'

    elseif strcmp(model_name, 'free_curvatures_free_weights')
        describeXfitFun(sub, Xfit([4:6,10:15],:))

    end
end

if any(contains(fun_names, 'recovery'))
    if (exist('constraint_param','var') == 1)
        [Xfit, nLL_best] = check_Xfit(constraint_param);
    else
        [Xfit, nLL_best] = check_Xfit();
    end
    
    [Xsim, sim] = simFun(sub, Xfit, model_name);
    
    if strcmp(model_name, 'free_curvatures')
        Xrec = recoveryFun(sim);
        plotRecoveryFun(Xsim([3:6,10:11],:), Xrec([3:6,10:11],:))
    elseif strcmp(model_name, 'free_curvatures_free_weights')
        Xrec = recoveryFun(sim);
        plotRecoveryFun(Xsim([4:6,10:15],:), Xrec([4:6,10:15],:))
    end

    % path to save output of recoveryFun()
    Xrec_path = [dataset_output_path '/' data_name '_' model_name '_Xrec'];
    save([Xrec_path '.mat'], 'Xrec', 'Xrec')
end


%% Export outputs
% if Xfit exists, write to file
if (exist('Xfit','var') == 1 && exist('nLL_best','var') == 1)
    disp(['write Xfit to ' Xfit_path]);
    
    % save to .mat file
    Xfit_path = [dataset_output_path '/' data_name '_' model_name '_Xfit'];
    if ~isfile([Xfit_path '.mat'])
        save([Xfit_path '.mat'], 'Xfit','nLL_best')
    end


    
    if size(Xfit, 2) == length(sub) % accomodate saving Xfit for free_weights model to csv 

        % matrix2csv(Xfit(1:6,:)', v_names(1:6)', Xfit_path)
        filenames = {sub(:).filename}; % cell array storing filename field of sub
        % Combine the cell array column and the matrix into a single cell array
        
        if strcmp(model_name, 'free_curvatures')
            Xfit_table = array2table(Xfit([3:6,10:11],:)',"VariableNames", v_names(1:6)');
        
        elseif strcmp(model_name, 'free_curvatures_free_weights')
            Xfit_fcfw1 = Xfit([4:6,10:15],:); % side, safe, inverse temp, eta gains, eta losses, reward1 2 3 4
            Xfit_fcfw2 = [Xfit_fcfw1; 1 - sum(Xfit_fcfw1(end-3:end,:))]; % add weight for reward5

            Xfit_table = array2table(Xfit_fcfw2',"VariableNames", v_names');
        
        end
        % add condition (nonsocial, nih_T, or nih_UT) as the 2nd column
        Xfit_table = addvars(Xfit_table, repmat(data_name, [height(Xfit_table), 1]), 'Before', 1, 'NewVariableNames','condition');
        % add filename column as the 1st column
        Xfit_table = addvars(Xfit_table, filenames', 'Before', 1, 'NewVariableNames', 'filename'); 
        % Write the combined data to a CSV file
        filename = [Xfit_path '.csv'];
        if ~isfile(filename)
            writetable(Xfit_table, filename);
        end
        
    end

end

% sub function
% nested functions to check whether intermediate variables exist, and read
% them if not
    function [Xfit, nLL_best] = check_Xfit(varargin) % optional argument to take constraint_param
    % check if Xfit is already in the local environment
    if (exist('Xfit','var') ~= 1)
        % if not, check whether a file that stores Xfit is available
        disp('xfit path')
        Xfit_path = [dataset_output_path '/' data_name '_' model_name '_Xfit'] % path to Xfit csv file
        % if isfile([Xfit_path '.csv'])
        if isfile([Xfit_path '.mat'])
            
            % disp('read Xfit csv file')
            disp('read Xfit mat file')
            % Xfit = readmatrix([Xfit_path '.csv']) % Xfit can be of n x 6 or 9
            % x n dimension, ambiguous
            % instead, load Xfit from '.mat' file
            loadVars = {'Xfit','nLL_best'};
            fitFun_output = load([Xfit_path '.mat'], loadVars{:});
            % Access the loaded data
            Xfit = fitFun_output.Xfit;
            nLL_best = fitFun_output.nLL_best;
    
        
        else
            % if neither exists, run fitFun to compute Xfit
            disp('compute Xfit on the fly')
            if nargin == 0
                % fitFun
                % constraint_param
                [Xfit, nLL_best, ~, ~, ~]  = fitFun(sub);
                
            elseif nargin > 0
                constraint_param = varargin{1};
                % fitFun
                % constraint_param
                [Xfit, nLL_best, ~, ~, ~]  = fitFun(sub, constraint_param);
            end
        end
    end
end

end
