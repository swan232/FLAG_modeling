function plot_para_recovery_v2(Xsim, Nfit, Xrec, v_symbol, v_names, data_name, model_name, remove_outliers, fig_save_dir)
% global font size
fontsize = 16;

% panel letters
panel_letters = 'ABCDEF';

% remove outliers
if remove_outliers
    Xsim = remove_parameter_outliers(Xsim);
    Xrec = remove_parameter_outliers(Xrec);
end

figure(2); clf; 
% set the size of the figure
set(gcf, 'Position', [100, 100, 1200, 800]); % Adjust the size as needed

if(size(Xsim,1) == 6) % eta, lambda, alpha, beta_side, beta_safe, beta_offer (inverse temperature)
    nx = 3; % 3 subplots each row
    ny = 2; % 2 rows
    
    % reorder free_curvatures model parameters based on the orders in which they were introduced 7/16/24
    if strcmp(model_name, 'free_curvatures')
        Xsim = Xsim([5 6 1 2 4 3], :);
        Xrec = Xrec([5 6 1 2 4 3], :);
        v_symbol = v_symbol([5 6 1 2 4 3]);
        v_names = v_names([5 6 1 2 4 3]);
    end

elseif (size(Xsim,1) == 10) || (size(Xsim,1) == 9) 
    % 10 free parameters: eta, lambda, alpha, beta_side, beta_safe, beta_offer (inverse temperature), beta_r1, beta_r2, beta_r3, beta_r4
    % 9 free parameters: % beta_side, beta_safe, beta_offer (inverse temperature), eta_gains, eta_losses, beta_r1, beta_r2, beta_r3, beta_r4: create 10 subplots
    
    % before plotting, add the weight for reward5
    
    Xsim = [Xsim; 1 - sum(Xsim(end-3:end,:))];
    Xrec = [Xrec; 1 - sum(Xrec(end-3:end,:))]; 
    nx = 4;
    ny = 3;

end

wg = ones(nx+1,1)*0.1;
hg = ones(ny+1,1)*0.1;
hg = ones(ny+1,1)*0.12; % increase vertical gap slightly to avoid overlap
wg(end) = 0.1;
hg(end) = 0.05;
wg(1) = .1;
hg(1) = .1;
ax = easy_gridOfEqualFigures(hg, wg);

for i = 1:size(Xsim,1)
    axes(ax(i)); hold on;
    [r,p] = corrcoef([Xsim(i,1:Nfit)' Xrec(i,1:Nfit)'], 'Rows','pairwise'); 
    r = r(2,1);
    p = p(2,1);


    if intersect(i, 3)
        plot(log10(Xsim(i,1:Nfit)), log10(Xrec(i,1:Nfit)),'.', 'Color', [0, 0, 0])
        xlabel(['simulated ' v_names{i} ', $\log_{10} ' v_symbol{i} '$'], 'interpreter', 'latex')
        ylabel(['fit ' v_names{i} ', $\log_{10} ' v_symbol{i} '$'], 'interpreter', 'latex')

    else
        plot(Xsim(i,1:Nfit), Xrec(i,1:Nfit),'.', 'Color', [0, 0, 0])
        xlabel(['simulated ' v_names{i} ', $\ ' v_symbol{i} '$'], 'interpreter', 'latex')
        ylabel(['fit ' v_names{i} ', $\ ' v_symbol{i} '$'], 'interpreter', 'latex')

    end
    xl = get(gca, 'xlim');
    plot(xl, xl,'--', 'LineWidth', 2, 'Color', [255, 202, 6]/256)


    % Create the string for p-value
    if p < 0.001
        p_string = ' p < 0.001';
    else
        p_string = sprintf(' p = %.2g', p);
    end

    text(0.05,0.9, sprintf(' r = %.2f, \n%s', r, p_string), 'units', 'normalized', 'FontSize', fontsize)

    % add panel letter
    text(-0.2, 1.03, panel_letters(i), 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold') % add panel letters
    
    % Adjust title position slightly below the default to prevent overlap
    title([v_names{i}], 'fontweight','normal' , 'Units', 'normalized', 'Position', [0.5, 1, 0]) % 8/27/24 add title back
    
end

set(ax, 'fontsize', fontsize) % set font size for axis labels


