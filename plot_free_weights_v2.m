function plot_free_weights_v2(sub, Xfit, v_symbol,v_names, data_name, model_name, remove_outliers, fig_save_dir, varargin)
UCFblack    = [0, 0, 0];
UCFgold     = [255, 202, 6]/256;

% plot 4 free weights models and free curvature free weights model
if contains(model_name, 'free_weights') 
    % compute the weight for the 5th draw
    Xfit = [Xfit; 1 - sum(Xfit(end-3:end,:))]; % size(Xfit,1) is now 11
    
    % remove outliers 
    if remove_outliers
        Xfit = remove_parameter_outliers(Xfit);
    end
    
    % extract the 5 weights from Xfit
    Xfit_weights = Xfit(end-4:end,:)'; 

    % Calculate mean and standard error
    mean_Xfit_weights = mean(Xfit_weights, 1, "omitmissing");  % Mean along the first dimension (columns)
    stderr_Xfit_weights = std(Xfit_weights, 0, 1,'omitmissing') / sqrt(size(Xfit_weights, 1));  % Standard error along the first dimension
    
    % Plot the mean with error bars representing the standard error
    figure(5); clf;
    set(gcf, 'position', [0, 100, 1000, 600])

    subplot(1,2,1)
    e1 = errorbar(1:size(Xfit_weights, 2), mean_Xfit_weights, stderr_Xfit_weights);
    set(e1, 'color', UCFgold, 'linewidth', 3, 'marker', '.', 'markersize', 50)
    xticks([1 2 3 4 5])
    % Customize the plot
    xlabel('Reward');
    ylabel('Mean Weight');
    set(gca, 'box', 'off')
    xlim([1 5]);
    xticks([1 2 3 4 5])
    ylim([0 .36])
    yticks([0, .1, .2, .3])
    title('weights of five rewards')
    set(gca,'FontSize',16)
    
    subplot(1,2,2)
    % plot aggregate weights by alpha 
    free_curvatures_loaded = load([pwd() '\sub_final\sub_final_free_curvatures_Xfit'],'Xfit');
    Xfit_fixed_weights  = free_curvatures_loaded.Xfit;
    alpha = Xfit_fixed_weights(3,:);
    subject_recency = find(alpha > 1);
    subject_primacy = find(alpha < 1);
    n_primacy = length(subject_primacy);
    n_recency = length(subject_recency);

    % Calculate mean and standard error
    Xfit_weights_primacy = Xfit_weights(subject_primacy,:);
    Xfit_weights_recency = Xfit_weights(subject_recency,:);
    mean_Xfit_weights_primacy = mean(Xfit_weights_primacy, 1, "omitmissing");  % Mean along the first dimension (columns)
    stderr_Xfit_weights_primacy = std(Xfit_weights_primacy, 0, 1,'omitmissing') / sqrt(size(Xfit_weights_primacy, 1));  % Standard error along the first dimension
    mean_Xfit_weights_recency= mean(Xfit_weights_recency, 1, "omitmissing");  % Mean along the first dimension (columns)
    stderr_Xfit_weights_recency = std(Xfit_weights_recency, 0, 1,'omitmissing') / sqrt(size(Xfit_weights_recency, 1));  % Standard error along the first dimension
    e2 = errorbar(1:size(Xfit_weights_primacy, 2), mean_Xfit_weights_primacy, stderr_Xfit_weights_primacy);
    set(e2, 'color', UCFgold, 'linewidth', 3, 'marker', '.', 'markersize', 50)
    hold on;
    e3 = errorbar(1:size(Xfit_weights_recency, 2), mean_Xfit_weights_recency, stderr_Xfit_weights_recency);
    set(e3, 'color', UCFblack, 'linewidth', 3, 'marker', '.', 'markersize', 50)
    legend({'primacy', 'recency'},'Location','northwest','Orientation','vertical','FontSize',16)
    
    xlim([1 5]);
    xticks([1 2 3 4 5])
    ylim([0 .36])
    yticks([0, .1, .2, .3])
    xlabel('Reward');
    ylabel('Weight');
    
    title({'weights of five rewards separate ', 'by participant response profile'})
    set(gca, 'box', 'off')
    set(gca,'FontSize',16)
    
end

