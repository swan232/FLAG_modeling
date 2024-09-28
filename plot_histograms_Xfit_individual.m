function plot_histograms_Xfit_individual(Xfit, selected_parameters, v_symbol,v_names, model_name, remove_outliers, fig_save_dir)
% remove outliers 
if remove_outliers
    Xfit = remove_parameter_outliers(Xfit);
end

% reorder free_curvatures model parameters based on the orders in which they were introduced 7/16/24
if strcmp(model_name, 'free_curvatures')
    Xfit = Xfit([5 6 1 2 4 3], :);
    v_symbol = v_symbol([5 6 1 2 4 3]);
    v_names = v_names([5 6 1 2 4 3]);

    % add lambda = eta_loss/eta_gain
    Xfit = [Xfit; Xfit(2,:) ./ Xfit(1,:)];
    v_symbol =[v_symbol; {'\lambda'}];
    v_names = [v_names; {'loss aversion'}];
end

for i = selected_parameters
    f=figure(4); clf; 
    set(gcf, 'Position', [0, 100, 600, 400]); % Adjust the width and height as needed

    if intersect(i, 7)
        histogram(log10(Xfit(i,:)),30,'FaceColor', [255, 202, 6]/256);
        n_gt1 = sum(Xfit(i,:) > 1);
        n_lt1 = sum(Xfit(i,:) <= 1);
        disp(['number of lambda > 1' num2str(n_gt1)])
        xlabel([v_names{i}, ', $\log_{10} ' v_symbol{i} '$'], 'interpreter', 'latex')
    else
        histogram(Xfit(i,:),30,'FaceColor', [255, 202, 6]/256);
        xlabel([v_names{i}, ', $\ ' v_symbol{i} '$'], 'interpreter', 'latex')
    end
    ylabel('number of participants')
    
    
    % adjust ylim of the histogram 
    % Get histogram counts
    [counts, ~] = histcounts(Xfit(i,:), 30);
    
    % Extract max count (y-axis value)
    maxY = max(counts);
    
    if i ~= 7
        ylim([0 90]) % set the same ylim (corresponding to subject count) for easy comparison
    end

    yl = get(gca, 'ylim');
    ymax = yl(2);

    % scale text label 
    yscale = 1.1;

    % if strcmp(v_symbol{i},'\eta')
    if contains(v_symbol{i},{'\eta','\eta_{+}', '\eta_{-}'})
        if strcmp(model_name, 'full')
            text(0.5, ymax * yscale , 'Concave', 'HorizontalAlignment', 'left')
            text(1.5, ymax * yscale, 'Convex', 'HorizontalAlignment', 'right')
        else
            % free curvatures free weights
            text(0, ymax * yscale , 'Concave', 'HorizontalAlignment', 'left')
            text(2, ymax * yscale, 'Convex', 'HorizontalAlignment', 'right')
        end

    elseif strcmp(v_symbol{i},'\lambda')
        
        % this is for free curvatures model computed lambda
        xlim([-13, 8])
        text(-10, ymax * yscale * .85, 'Loss seeking', 'HorizontalAlignment', 'left', 'FontSize',16)
        text(7, ymax * yscale * .85, 'Loss aversion', 'HorizontalAlignment', 'right', 'FontSize',16)

    elseif strcmp(v_symbol{i},'\alpha')
        
        xlim([-5, 20])
        text(-4, ymax * yscale, 'Primacy', 'HorizontalAlignment', 'left')
        text(6, ymax * yscale, 'Recency', 'HorizontalAlignment', 'right')
        
    elseif strcmp(v_symbol{i},'\beta_{side}')
        
        text(-2, ymax * yscale , 'Left bias', 'HorizontalAlignment', 'left')
        text(2, ymax * yscale, 'Right bias', 'HorizontalAlignment', 'right')
    elseif strcmp(v_symbol{i},'\beta_{safe}')
        
        xlim([-3, 3])
        text(-2, ymax * yscale, 'Deck bias', 'HorizontalAlignment', 'left')
        text(2, ymax * yscale, 'Safe bias', 'HorizontalAlignment', 'right')
    elseif strcmp(v_symbol{i},'\beta_{offer}')
        xlim([-0.1, 0.1])
    
        if strcmp(model_name, 'free_curvatures_free_weights')
            text(-0.09, ymax * (yscale-.1), 'Anti-utility', 'HorizontalAlignment', 'left')
            text(-0.03, ymax * yscale, 'Utility-agnostic', 'HorizontalAlignment', 'left')
            text(0.09, ymax * (yscale-.1),  'Pro-utility', 'HorizontalAlignment', 'right')
        else
            text(-0.09, ymax * yscale, 'Anti-utility', 'HorizontalAlignment', 'left')
            text(-0.03, ymax * yscale, 'Utility-agnostic', 'HorizontalAlignment', 'left')
            text(0.09, ymax * yscale,  'Pro-utility', 'HorizontalAlignment', 'right')
        end

    elseif strcmp(v_symbol{i},'\eta_{+}')
        text(0, ymax * yscale , 'Concave', 'HorizontalAlignment', 'left')
        text(2, ymax * yscale, 'Convex', 'HorizontalAlignment', 'right')
    
    elseif strcmp(v_symbol{i},'\eta_{-}')
        text(0.5, ymax * yscale , 'Concave', 'HorizontalAlignment', 'left')
        text(1.5, ymax * yscale, 'Convex', 'HorizontalAlignment', 'right')
    end
    
    if intersect(i, [1 2 3])
        b = 1;
    else
        b = 0;
    end
    % add vertical line for boundary parameter value
    xline(b, '--k');
    set(gca, 'box', 'off')
    
    annotation('doublearrow', [.13 .6098], [.9250 .9250], 'Color', 'black'); % Adjust coordinates
    annotation('doublearrow', [.6098 .90], [.9250 .9250], 'Color', 'black'); % Adjust coordinates
    
end
