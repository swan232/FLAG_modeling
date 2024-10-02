function describe_model_parameter(sub, Xfit, v_symbol, v_names, data_name, model_name, remove_outliers, fig_save_dir) 

if remove_outliers
    Xfit = remove_parameter_outliers(Xfit);
end

path_describeXfit = [fig_save_dir '\' data_name '_' model_name '_describeXfit.txt'];
if exist(path_describeXfit, 'file')
    delete(path_describeXfit); 
end

diary(path_describeXfit)
diary on

if strcmp(model_name,'free_curvatures')
    %% curvature for gains
    disp('***************************************Curvature for gains ***************************************')
    curvature = Xfit(5,:); % compare with 1, < 1 concave, outliers undervalued; 0 magnitude ignored only signs matter; > 1 convex, outlier overvalued;
    mean_curvature = mean(curvature, "omitmissing");
    sd_curvature = std(curvature, "omitmissing");
    [~, p, ci, stats] = ttest(curvature, 1)
    n_concave = sum(curvature < 1); 
    n_eta = sum(~isnan(curvature));
    n_near0_gains = sum(abs(curvature - 0) < .001);

    disp(['Mean curvature for gains is ' num2str(mean_curvature) ', sd is ' num2str(sd_curvature) ', ' num2str(n_concave) ' of ' num2str(n_eta) ' subjects show diminishing sensitivity, ' ...
        'different from 1, p = ' num2str(p) ' two tailed, number of near zero curvature: ' num2str(n_near0_gains)])
    
    %% curvature for losses
    disp('***************************************Curvature for losses ***************************************')
    curvature = Xfit(6,:); % compare with 1, < 1 concave, outliers undervalued; 0 magnitude ignored only signs matter; > 1 convex, outlier overvalued;
    mean_curvature = mean(curvature, "omitmissing");
    sd_curvature = std(curvature, "omitmissing");
    [~, p, ci, stats] = ttest(curvature, 1)
    n_concave = sum(curvature < 1); %157
    n_eta = sum(~isnan(curvature));
    n_near0_losses = sum(abs(curvature - 0) < .001);
    
    disp(['Mean curvature for losses is ' num2str(mean_curvature) ', sd is ' num2str(sd_curvature) ',' num2str(n_concave) ' of ' num2str(n_eta) ' subjects show diminishing sensitivity, ' ...
        'different from 1, p = ' num2str(p) ' two tailed, number of near zero curvature: ' num2str(n_near0_losses)])
    
    n_near0_both = sum((abs(Xfit(5,:) - 0) < .001) & (abs(Xfit(6,:) - 0) < .001));
    disp(['number of near zero for both gains and losses: ' num2str(n_near0_both)])
    %% compare eta+ and eta-
    disp('******************Curvature for gains vs. losses ************************')
    [h, p, ci, stats] = ttest(Xfit(5,:), Xfit(6,:))
    
    %% loss averse
    disp('***************************************Loss aversion***************************************')
    loss.aversion = Xfit(6,:) ./ Xfit(5,:); % compare with 1
    mean_lossaversion = mean(loss.aversion,"omitmissing")
    sd_lossaversion = std(loss.aversion,"omitmissing")
    
    [~, p, ci, stats] = ttest(loss.aversion, 1, 'alpha', .05, 'tail', 'right')
    n_lossaversion = sum(loss.aversion > 1); % 64
    n_lambda = sum(~isnan(loss.aversion));
    disp(['Mean loss aversion is ' num2str(mean_lossaversion) ', standard deviation is ' num2str(sd_lossaversion) ', ' num2str(n_lossaversion) ' of ' num2str(n_lambda) ' subjects show loss aversion (lambda > 1), ' ...
        'greater than 1, p = ' num2str(p) ' one tailed'])
    
    
    %% primacy-recency effect
    disp('***************************************Primacy-Recency***************************************')
    primacy.recency  = Xfit(1,:);
    mean_primacy.recency = mean(primacy.recency ,'omitmissing');
    sd_primacy.recency= std(primacy.recency,"omitmissing")
    [~, p, ci, stats] = ttest(primacy.recency , 1)
    n_recency = sum(primacy.recency  > 1); % 114 show recency effect
    n_alpha = sum(~isnan(primacy.recency ));
    disp(['Mean alpha is ' num2str(mean_primacy.recency) ', sd is ' num2str(sd_primacy.recency) ',' num2str(n_recency) ' of ' num2str(n_alpha) ' subjects show recency bias (alpha < 1), ' ...
        'different from 1, p = ' num2str(p) ' two tailed'])
    
    %% side bias
    disp('***************************************Side bias***************************************')
    side.bias = Xfit(2,:); % 0
    mean_sidebias = mean(side.bias,'omitmissing');
    sd_sidebias = std(side.bias,"omitmissing")
    [~, p, ci, stats] = ttest(side.bias, 0)
    n_rightbias = sum(side.bias > 0 ); % 91
    n_side = sum(~isnan(side.bias));
    if (p > 0.05)
        disp(['Mean side.bias is ' num2str(mean_sidebias) ', sd = ', num2str(sd_sidebias) ', ' num2str(n_rightbias) ' of ' num2str(n_side) ' subjects show right bias, '...
            num2str(n_side - n_rightbias) ' of ' num2str(n_side) ' subjects show left bias, subjects show no side bias, p = ' num2str(p) ' two tailed'])
    end
    
    
    %% safe bias
    disp('***************************************Safe bias***************************************')
    safe.bias = Xfit(3,:); % 
    mean_safebias = mean(safe.bias, 'omitmissing');
    sd_safebias = std(safe.bias, 'omitmissing');
    [~, p, ci, stats] = ttest(safe.bias, 0)
    n_deckbias = sum(safe.bias < 0 ); 
    n_safe = sum(~isnan(safe.bias));
    
    disp(['Mean safe bias is ' num2str(mean_safebias) ' sd = ' num2str(sd_safebias) ', ' num2str(n_deckbias) ' of ' num2str(n_safe) ' subjects show a deck bias (safe.bias < 0), ' ...
        'different from 0, p = ' num2str(p) ' two tailed'])
    
    %% inverse temperature
    disp('***************************************Inverse temperature***************************************')
    inverse.temperature = Xfit(4,:); % 0
    mean_inversetemperature = mean(inverse.temperature,'omitmissing');
    sd_inversetemperature = std(inverse.temperature, 'omitmissing');
    n_deterministic = sum(inverse.temperature > 0);
    n_inversetemperature = sum(~isnan(inverse.temperature));
    [~, p, ci, stats] = ttest(inverse.temperature, 0, 'alpha', .05, 'tail', 'right')
    
    disp(['Mean inverse temperature is ' num2str(mean_inversetemperature) ' sd: ' num2str(sd_inversetemperature) ', ' num2str(n_deterministic) ' of ' num2str(n_inversetemperature) ' subjects show deterministic/exploitative behavior (inverse.temperature > 0), ' ...
        'greater than 0, p = ' num2str(p) ' one tailed'])
    
end

diary off


%% Xfit correlation matrix
plot_correlation_matrix_Xfit_v2(sub, Xfit, v_symbol, v_names, data_name, model_name, remove_outliers, fig_save_dir)

%% plot 5 free weights
plot_free_weights_v2(sub, Xfit, v_symbol,v_names, data_name, model_name, remove_outliers, fig_save_dir)
