function plot_histograms_Xfit_v2(Xfit, v_symbol,v_names, data_name, model_name, remove_outliers, fig_save_dir)

% global font size
fontsize = 16;

% panel letters
panel_letters = 'ABCDEF';

% remove outliers 
if remove_outliers
    Xfit = remove_parameter_outliers(Xfit);
end

figure(1); clf; 
% set the size of the figure
set(gcf, 'Position', [100, 100, 1200, 800]); % Adjust the size as needed

% create subplot based on the set of parameters in Xfit

if(size(Xfit,1) == 6) 
    
    % reorder free_curvatures model parameters based on the orders in which they were introduced
    if strcmp(model_name, 'free_curvatures')
        Xfit = Xfit([5 6 1 2 4 3], :);
        v_symbol = v_symbol([5 6 1 2 4 3]);
        v_names = v_names([5 6 1 2 4 3]);
    end

    nx = 3; % 3 subplots each row
    ny = 2; % 2 rows
    hg = [0.1 0.17 0.07]; 
    wg = [0.1 0.075 0.075 0.03];

% plot free weights model parameters 
elseif (size(Xfit,1) == 10) || (size(Xfit,1) == 9) 
    
    % before plotting, add the weight for reward5
    Xfit = [Xfit; 1 - sum(Xfit(end-3:end,:))]; % size(Xfit,1) is now 11

    nx = 4;
    ny = 3;
    hg = [0.12 0.075 0.075 0.06];
    wg = [0.12 0.075 0.075 0.06 0.06]; % make subplot wider to avoid text cutoff

end

ax = easy_gridOfEqualFigures(hg, wg);

% for i = 1:6
for i = 1:size(Xfit, 1)
    axes(ax(i));
    hold on;
    if intersect(i, 3)
        h = histogram(log10(Xfit(i,:)),30,'FaceColor', [255, 202, 6]/256);
        xlabel([v_names{i}, ', $\log_{10} ' v_symbol{i} '$'], 'interpreter', 'latex')
    else
        h = histogram(Xfit(i,:),30,'FaceColor', [255, 202, 6]/256);
        xlabel([v_names{i}, ', $\ ' v_symbol{i} '$'], 'interpreter', 'latex')
    end

    title([v_names{i}], 'fontweight','normal' , 'Units', 'normalized', 'Position', [0.5, 1.1, 0]) 
    text(-0.18, 1.06, panel_letters(i), 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold') % add panel letters
    
    % Get histogram counts
    [counts, ~] = histcounts(Xfit(i,:), 30);

    % Set y-axis limits
    ylim([0 90]) % set the same ylim (corresponding to subject count) for easy comparison
    yl = get(gca, 'ylim');
    ymax = yl(2);

    % scale text label (e.g., 'Concave', 'Primacy', etc.)
    yscale = 1.05;

    if strcmp(v_symbol{i},'\lambda')
        xline(1, '--k');
        xlim([-5, 11]);
        text(-4, ymax * yscale, 'Loss seeking', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
        text(6, ymax * yscale, 'Loss aversion', 'HorizontalAlignment', 'right', 'FontSize', fontsize);
    
    elseif strcmp(v_symbol{i},'\alpha')
        xlim([-2,2]); % symmetrical for alpha
        text(-1.5, ymax * yscale, 'Primacy', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
        text(1.5, ymax * yscale, 'Recency', 'HorizontalAlignment', 'right', 'FontSize', fontsize);
        
    elseif strcmp(v_symbol{i},'\beta_{side}')
        xlim([-4, 4]); % symmetrical for side bias
        text(-3, ymax * yscale , 'Left bias', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
        text(3.2, ymax * yscale, 'Right bias', 'HorizontalAlignment', 'right', 'FontSize', fontsize);
    
    elseif strcmp(v_symbol{i},'\beta_{safe}')
        xlim([-3, 3]);
        text(-2.5, ymax * yscale, 'Deck bias', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
        text(2.5, ymax * yscale, 'Safe bias', 'HorizontalAlignment', 'right', 'FontSize', fontsize);
    
    elseif strcmp(v_symbol{i},'\beta_{r}')
        xlim([-0.1, 0.1]);
        if strcmp(model_name, 'free_curvatures_free_weights')
            text(-0.09, ymax * (yscale-.1), 'Anti-utility', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
            text(-0.03, ymax * yscale, 'Utility-agnostic', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
            text(0.09, ymax * (yscale-.1),  'Pro-utility', 'HorizontalAlignment', 'right', 'FontSize', fontsize);
        else
            text(-0.11, ymax * yscale, 'Anti-utility', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
            text(-0.04, ymax * yscale, 'Utility-agnostic', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
            text(0.12, ymax * yscale,  'Pro-utility', 'HorizontalAlignment', 'right', 'FontSize', fontsize);
        end

    elseif strcmp(v_symbol{i},'\eta_{+}')
        % Set x-axis limits for eta+
        xlim([0, 4]);
        text(0, ymax * yscale , 'Concave', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
        text(3, ymax * yscale, 'Convex', 'HorizontalAlignment', 'right', 'FontSize', fontsize);
    
    elseif strcmp(v_symbol{i},'\eta_{-}')
        % Set x-axis limits for eta-
        xlim([0, 4]);
        text(0, ymax * yscale , 'Convex', 'HorizontalAlignment', 'left', 'FontSize', fontsize);
        text(3, ymax * yscale, 'Concave', 'HorizontalAlignment', 'right', 'FontSize', fontsize);
    end
    
    if intersect(i, [1 2])
        b = 1;
    else
        b = 0;
    end
    % add vertical line for boundary parameter value
    xline(b, '--k', 'LineWidth', 2);

    % left, bottom, width, and height of subplot normalized
    ax_pos = ax(i).Position;
    % get xlim ylim
    xl = get(gca, 'xlim');
    yl = get(gca, 'ylim');

    add_double_arrow(ax_pos, xl, yl, b);
    % set the Bin width to be proportional to the x range to make bin width
    % look consistent across subplots
    h.BinWidth = (xl(2) - xl(1)) /30;
    
end

% Determine the number of subplots and delete any extra ones
n_plots = size(Xfit,1);
if n_plots < length(ax)
    for i = n_plots+1:length(ax)
        delete(ax(i));
    end
    ax(n_plots+1:end) = [];
end

yt = get(ax(1), 'ytick');
set(ax, 'fontsize', fontsize) % set font size for axis labels
axes(ax(1)); ylabel('number of participants')
axes(ax(4)); ylabel('number of participants')
