function plot_correlation_matrix_Xfit_v2(sub, Xfit, v_symbol, v_names, data_name, model_name, remove_outliers, fig_save_dir)

% load subject avg point and proportion choosing high mean
data = readtable('subject_mean_point_phigh.csv');
if strcmp(model_name, 'free_curvatures')
        Xfit = Xfit([5 6 1 2 4 3], :);
        v_symbol = v_symbol([5 6 1 2 4 3]);
        v_names = v_names([5 6 1 2 4 3]);
end

Xfit = [Xfit; Xfit(2,:) ./ Xfit(1,:); data.mean_score'; data.p_high'];
v_symbol = [v_symbol; {'\lambda_{computed}'}; {'Avg_{point}'}; {'p(high mean)'}];
v_names = [v_names;  {'\lambda_{computed}'}; {'Avg_{point}'}; {'p(high mean)'}];

% remove outliers 
if remove_outliers
    Xfit = remove_parameter_outliers(Xfit);
end

% indices of parameters with non-zero standard deviation 
idx_to_keep = find(abs(std(Xfit, [], 2, 'omitmissing') - 0) > 0.00001);
Xfit = Xfit(idx_to_keep,:);
v_symbol = v_symbol(idx_to_keep);
v_names = v_names(idx_to_keep);

% correlations between parameters
% if Xfit is the output of full model or nested model without free weights
if ~contains(model_name, 'free_weights') 
    [r,p] = corr(Xfit', 'type', 'spearman', 'Rows', 'pairwise');
else
    % add weight for reward5
    Xfit = [Xfit; 1 - sum(Xfit(end-3:end,:))]; % size(Xfit,1) is now 11
    [r,p] = corr(Xfit', 'type', 'spearman', 'Rows', 'pairwise');
end

% Apply Holm's correction to p-values https://www.mathworks.com/matlabcentral/fileexchange/28303-bonferroni-holm-correction-for-multiple-comparisons
p = bonf_holm(p, .05);

figure(6); clf;
set(gcf, 'Position', [100, 100, 1200, 800]); 
ax = gca;
r = r- diag(diag(r));
t = imageTextMatrixStars_v3(round(r*100)/100, p, 0.05);
set(t, 'fontsize', 18)
hold on;

colorbar

set(gca, 'clim', [-1 1], 'xtick', 1:length(v_symbol), ...
    'xticklabel', v_symbol, 'ytick', 1:length(v_symbol), ...
    'yticklabel', v_symbol, ...
    'fontsize', 18, ...
    'XAxisLocation', 'top') % Move X-axis labels to the top


% Rotate tick labels for better visibility 
xtickangle(90)

