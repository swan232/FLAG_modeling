clear

%% directories
fundir = pwd();
datadir = [fundir '/data_demo'];
figdir = [fundir '\fig'];
mkdir(figdir)

%% colors
global UCFblack UCFgold

UCFblack    = [0, 0, 0];
UCFgold     = [255, 202, 6]/256;

% full model v_names and v_symbols
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


%% load nonsocial FLAG data
cd(fundir)
% sub = load_data_UCF(datadir); 
% save("sub_nonsocial.mat", "sub")

% load data from mat files
load("sub_nonsocial.mat")
% save('global_variables')


%% ========================================================================
%% basics of the data %% basics of the data %% basics of the data %%
%% basics of the data %% basics of the data %% basics of the data %%
%% basics of the data %% basics of the data %% basics of the data %%
%% ========================================================================

%% how many subjects?
disp(['n subjects = ' num2str(length(sub))])

%% how many trials
disp(['n trials = ' num2str(sub(1).trials)])

%% number of male and female participants
[sub_male, sub_female] = group_by_gender(sub);
% age
age = cellfun(@(x) unique(x), {sub.age});
mean(age)
std(age)
max(age)
min(age)

%% how many "loss-aversion" trials are there where we mix gains and losses?
n_mixed = nan(1, length(sub));
f_mixed = nan(1, length(sub));
for sn = 1:length(sub)
    ss = sum([sub(sn).game.rewards]>0); % of 5 forced trial per game, how many outcomes are rewards (positive)
    ind = ss~=5 & ss~=0;  % logic value of games with mixed gains and losses
    n_mixed(sn) = sum(ind); % of 100 games per participant, how many games are mixed
    f_mixed(sn) = mean(ind); % proportion mixed
end

n_mixed
f_mixed

%% Figure 2 Utility As a Function of Both Curvature for Gains (η_+) and Curvature for Losses (η_-)
figure(1);clf;
set(gcf, 'Position', [100, 0, 1000, 1000]); % Adjust the size as needed
% panel letters
panel_letters = 'ABCD';
R = -100:1:100;
color_list = [26, 133, 255;
              212, 17, 89;
              230, 97, 0;
              93, 58, 155]/256;

eta_gains_list = [.5, .8, 1, 1.2];
eta_losses_list = [.75, .8, 1, 0.8];
title_list = {'loss aversion', 'no preference', 'no preference', 'gain seeking'};
lambda = 1;

for i = 1:length(eta_gains_list)
    eta_gains = eta_gains_list(i);
    eta_losses = eta_losses_list(i);
    color = color_list(i,:);
    subplot(2,2,i)
    Ur = compute_utility_v2(R, eta_gains, eta_losses, lambda);
    plot(R, Ur, 'Color', color, 'LineWidth', 3)
    xlabel('Reward value','FontSize',16);
    ylabel('Utility','FontSize',16);
    xline(0, '--k','LineWidth',2)
    yline(0,'--k','LineWidth',2)
    title(title_list{i}, ['$\eta_{+} = $' num2str(eta_gains) '$, \eta_{-} = $' num2str(eta_losses)], ...
        'Interpreter', 'latex','FontSize',26, 'FontWeight','bold')
    text(-0.2, 1.06, panel_letters(i), 'Units', 'normalized', 'FontSize', 26, 'FontWeight', 'bold') % add panel letters
    set(gca, 'box', 'off')
    set(gca,'FontSize',16)
    hold on;
end

%% Figure 3 Weights For the Five Rewards as A Function of Primacy-Recency Parameter 
figure(1);clf;
set(gcf, 'Position', [0, 100, 600, 400]); % Adjust the width and height as needed
alphas = [1/100, 1/2, 1, 2, 100];
% Define UCFblack and UCFgold colors
UCFblack = [0, 0, 0];
UCFgold  = [255, 202, 6]/256;
% Number of gradient colors to generate (including UCFblack and UCFgold)
numColors = 5;
gradientColors = gradient_colors(UCFgold, UCFblack, 5);
titles = {'A','B', 'C', 'D', 'E'};
for i = 1:length(alphas)
    alpha = alphas(i);
    plot(alpha_weights(alpha), 'linewidth', 3, 'color', gradientColors(i,:))
    xlabel('Reward')
    ylabel('Weight')
    xlim([1 5])
    xticks([1 2 3 4 5])
    hold on
    
end

legend(arrayfun(@(alpha) ['\alpha = ' num2str(alpha)], alphas, 'UniformOutput', false), 'Location','southoutside','Orientation', 'horizontal')

ax = gca;
ax.FontSize = 16;

%% Figure 4 Choice Curve for Difference Values (R_deck-R_offer) 
figure(1); clf;
set(gcf, 'Position', [0, 100, 600, 400]); % Adjust the width and height as needed

gradientColors = gradient_colors(UCFgold, UCFblack, 4);
subplot(1,2,1)
plot_beta_r_utility(gradientColors, 3)
% Move title 'A' to the upper left corner outside the subplot
text(-0.18, 1.06, 'A', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold')

subplot(1,2,2)
plot_beta_safe_utility(gradientColors, 3)
% Move title 'A' to the upper left corner outside the subplot
text(-0.18, 1.06, 'B', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold')

%% Figure 5 Parameter Recovery Plot for The Base Cognitive Model

load([pwd() '\sub_final\sub_final_free_curvatures_Xfit']);
load([pwd() '\sub_final\sub_final_free_curvatures_sim']);
load([pwd() '\sub_final\sub_final_free_curvatures_Xrec']);
% free curvatures v_names and v_symbols
v_symbol =  [v_symbol(3:6);{'\eta_{+}', '\eta_{-}'}'];
v_names = [v_names(3:6); {'curvature for gains', 'curvature for losses'}'];


plotRecoveryFun = @(x, y) plot_para_recovery_v2(x,... % first output of sim_all_full()
                                               size(x, 2),... 
                                               y, ...% output of recoveryFun, e.g., Xrec(1:6,:) or Xrec([1:6, 10:13],:)
                                               v_symbol, v_names, ...% global variables of parameter names
                                               'sub_final', 'free_curvatures', ...% name of the model
                                               true, ...% whether outlier fit values are removed
                                               pwd);


plotRecoveryFun(Xfit([3:6,10:11],:), Xrec([3:6,10:11],:));

%% Figure 6 Basic performance in the FLAG Task
% distribution of mean score and RT 
% what would be the avg point if a person behaves randomly?
sub1 = sub(1);
meanR = mean([sub1.game.rewards]); % 5 x 100 matrix
O = [sub1.game.offer];
mean_score_random = mean([meanR O]); % mean(meanR / 2 + O /2)

figure(1); clf;
set(gcf, 'Position', [0, 100, 600, 250]); % Adjust the width and height as needed

subplot(1,2,1)
% compute total reward
sub = compute_score(sub);
histogram([sub.mean_score], -30:10:100, 'FaceColor', UCFgold)
xlabel('Average points per game')
ylabel('Number of subjects')
xlim([-10 100])
ylim([0 60])

% add vertical dashed line for mean score obtained for random response
xline(mean_score_random, '--k', 'LineWidth',2);

% Annotation
% Get axis limits
xl = get(gca, 'xlim'); 
yl = get(gca, 'ylim'); 
pos = get(gca, 'Position'); % get the position of the subplot
% Compute normalized coordinates for the textarrow, convert the desired
% coordinates from the subplot's axis to the figure's normalized
% coordinates
x_norm = pos(1) + pos(3) * (mean_score_random - xl(1)) / (xl(2) - xl(1));
y_norm = pos(2) + pos(4) * 0.9;  % Adjust the 0.9 as needed for arrow placement in y-direction
% Add the textarrow annotation pointing to the dashed line
annotation('textarrow', [x_norm+0.05, x_norm], [y_norm+0.05, y_norm], 'String', 'Random responding');

title({'average points per game'})
% Move title 'A' to the upper left corner outside the subplot
text(-0.18, 1.06, 'A', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold')
set(gca, 'box', 'off')
hold on;

subplot(1,2,2)
rt_dist = get_rt_dist(sub);
histogram(rt_dist.RT/1000, 10, 'FaceColor',UCFgold)
xlabel('Mean RT (s)');
ylabel('Number of subjects')
title('RT')
% Move title 'B' to the upper left corner outside the subplot
text(-0.18, 1.06, 'B', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold')
set(gca, 'box', 'off')

%% Appendix A 
% behavior over course of game: replicating choseHIghMean and rt with cellfun and vectorization (not working with NaN!)
clearvars R O C T Rmat Omat Cmat Tmat
% rewards
R = cellfun(@(x) mean([x.rewards], "omitmissing"), {sub.game}, 'UniformOutput',false);
% offer
O = cellfun(@(x) [x.offer], {sub.game}, 'UniformOutput', false);
% choseDeck
C = cellfun(@(x) [x.choseDeck], {sub.game},'UniformOutput',false);
% rt
T = cellfun(@(x) [x.rt], {sub.game}, 'UniformOutput', false);

Rmat = reshape(cell2mat(R), length(sub(1).game),[]);
Omat = reshape(cell2mat(O), length(sub(1).game), []);
Cmat = reshape(cell2mat(C), length(sub(1).game), []); 
Tmat = reshape(cell2mat(T), length(sub(1).game), [])/1000;

isDeckHighMean = double(Rmat - Omat > 0); 
choseHighMean1 = double(isDeckHighMean == Cmat);
choseHighMean1(isnan(Cmat)) = NaN;

figure(1);clf;
set(gcf, 'Position', [0, 100, 1300, 600]); % Adjust the width and height as needed
subplot(1,2,1)
plot(mean(choseHighMean1, 2, "omitmissing"), 'linewidth', 2,'Color', UCFgold)
xlabel('Trial number');
ylabel('p(chose high mean)')
title('proportion choosing high-mean over 100 trials')
% Move title 'A' to the upper left corner outside the subplot
text(-0.18, 1.06, 'A', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold')
set(gca, 'box','off')
set(gca, 'FontSize',16)
hold on;

subplot(1,2,2)
plot(mean(Tmat, 2, "omitmissing"),'linewidth',2, 'Color',UCFgold)
xlabel('Trial number');
ylabel('Response time [seconds]')
title('RT over 100 trials')
% Move title 'B' to the upper left corner outside the subplot
text(-0.18, 1.06, 'B', 'Units', 'normalized', 'FontSize', 14, 'FontWeight', 'bold')
set(gca, 'box','off')
set(gca, 'FontSize',16)
hold off;

%% Figure 7 Average Choice Curve, Sensitivity, and Bias
% average choice curve for all subjects
figure(1); clf;
set(gcf, 'Position', [0, 100, 1600 , 650 ]); % Adjust the width and height as needed

ax1 = subplot(1,3,1);
plot_choiceCurves_v1(ax1, sub); % Pass the axes handle for the first subplot
ylim([0 1])
xline(0, '--k','LineWidth',2)
yline(0.5,'--k','LineWidth',2)
title('average choice curve')
text(-0.18, 1.06, 'A', 'Units', 'normalized', 'FontSize', 20, 'FontWeight', 'bold')
set(ax1, 'box', 'off')
set(ax1,'FontSize', 20)
hold on;

% distribution of sensitivity and bias

% fit sigmoid model to individual choice curve to obtain bias and sensitivity measures 
bias_n = nan(1, length(sub));
sensitivity_n = nan(1, length(sub));
for i = 1:length(sub)
    [bias_n(i), sensitivity_n(i), resnorm, residual] = fit_sigmoid_function_choice_curve(sub(i), false);
end

subplot(1,3,2)
ax2 = subplot(1,3,2);
h1 = histogram(sensitivity_n, 'FaceColor', UCFgold);
xlabel('sensitivity')
ylabel('count')
ylim([0 150]);
xlim([-50 50]);
% set the Bin width to be proportional to the x range to make bin width
% look consistent across subplots
xl = get(ax2, 'xlim');
yl = get(ax2, 'ylim');
h1.BinWidth = (xl(2) - xl(1)) /30;
xline(0, '--k','LineWidth',2)
title('sensitivity')
text(-0.18, 1.06, 'B', 'Units', 'normalized', 'FontSize', 20, 'FontWeight', 'bold')
set(ax2, 'box', 'off')
set(ax2,'FontSize',20)
hold on;

ax3 = subplot(1,3,3);
h2 = histogram(bias_n,'FaceColor', UCFgold);
xlabel('bias')
ylabel('count')
ylim([0 150]);
xlim([-50 50]);
% get xlim ylim
xl = get(ax3, 'xlim');
yl = get(ax3, 'ylim');
% set the Bin width to be proportional to the x range to make bin width
% look consistent across subplots
h2.BinWidth = (xl(2) - xl(1)) /30;

xline(0, '--k','LineWidth',2)
title('bias')    
text(-0.18, 1.06, 'C', 'Units', 'normalized', 'FontSize', 20, 'FontWeight', 'bold')
set(ax3, 'box', 'off')
set(ax3,'FontSize',20)
hold off;

%% sensitivity and bias
mean(sensitivity_n)
std(sensitivity_n)
[h, p, ci, stats] = ttest(sensitivity_n, 0, 'alpha', .05, 'tail', 'right')
mean(bias_n)
std(bias_n)
[h, p, ci, stats] = ttest(bias_n, 0, 'alpha', .05, 'tail', 'both')


%% ========================================================================
%% model-based analysis %% model-based analysis %% model-based analysis %%
%% model-based analysis %% model-based analysis %% model-based analysis %%
%% model-based analysis %% model-based analysis %% model-based analysis %%
%% ========================================================================

%% Figure  5, 8, 10, 12 
load('sub_nonsocial.mat')
main_v4_UCF(sub, 'sub_final', length(sub), 'free_curvatures', {'fit','histogram','sim','choice','recovery','choice','describeXfit'})

%% Figure 8  Histogram Of Parameter Values in the Base Cognitive Model with Outliers Removed
load([pwd() '\sub_final\sub_final_free_curvatures_Xfit']);
load('global_variables.mat')
% free curvatures v_names and v_symbols
v_symbol =  [v_symbol(3:6);{'\eta_{+}', '\eta_{-}'}'];
v_names = [v_names(3:6); {'curvature for gains', 'curvature for losses'}'];

histFun = @(x, y, z) plot_histograms_Xfit_v2(x, ...% x: fit values
    v_symbol, v_names, ...
    y,... % name of the dataset
    z, ...% name of the model
    true, ... % whether outlier fit values are removed
    pwd());
histFun(Xfit([3:6,10:11],:), 'sub_test', 'free_curvatures');


%% Figure 9 Histogram Of Computed Lambda Values (η_-/η_+) with Outliers Removed
% lambda histogram
load([fundir '\sub_final\sub_final_free_curvatures_Xfit.mat'])

% free curvatures Xfit, v_names and v_symbols
Xfit = Xfit([3:6,10:11],:);
v_symbol =  [v_symbol(3:6);{'\eta_{+}', '\eta_{-}'}'];
v_names = [v_names(3:6); {'curvature for gains', 'curvature for losses'}'];
plot_histograms_Xfit_individual(Xfit, 7, v_symbol,v_names, 'free_curvatures', false, pwd)
set(gca, 'FontSize',16)


%% Figure 10 Average Choice Curve Based on Observed and Simulated Data
% choice curve
load([pwd() '\sub_final\sub_final_free_curvatures_Xfit']);
load([pwd() '\sub_final\sub_final_free_curvatures_sim']);
load([pwd() '\sub_final\sub_final_free_curvatures_Xrec']);
load('global_variables.mat')

% free curvatures v_names and v_symbols
v_symbol =  [v_symbol(3:6);{'\eta_{+}', '\eta_{-}'}'];
v_names = [v_names(3:6); {'curvature for gains', 'curvature for losses'}'];

choiceCurveFun = @(x) plot_choiceCurves_v2(sub, ... 
        'sub_final', 'free_curvatures', ...
        pwd, ... % e.g., fig_save_dir
        1, x);
        % x: sim

choiceCurveFun(sim)

ax = gca;
ax.XAxis.FontSize = 16;
ax.YAxis.FontSize = 16;

%% Figure 11 Weights for the Five Rewards Based on the Free-Weight Model
% plot free weights
main_v4_UCF(sub, 'sub_freeweights', length(sub), 'free_curvatures_free_weights', {'fit'})
load([pwd() '\sub_freeweights\sub_freeweights_free_curvatures_free_weights_Xfit']);
load('global_variables.mat')
% free curvatures free weights v_names and v_symbols
v_symbol =  [v_symbol(4:6);{'\eta_{+}', '\eta_{-}'}'; {'\beta_{r1}', '\beta_{r2}','\beta_{r3}','\beta_{r4}','\beta_{r5}'}'];
    
v_names = [v_names(4:6); {'curvature for gains', 'curvature for losses'}';{'reward1 weight', 'reward2 weight', 'reward3 weight', 'reward4 weight', 'reward5 weight'}'];

plot_free_weights_v2(sub, Xfit, v_symbol,v_names, 'sub_final', 'free_curvatures_free_weights', true, pwd)

%% Figure 12 Intercorrelations Between Individual Differences in Parameter Values, Average Points, and Probability of Choosing the High Mean Option
% parameter cor matrix heatmap with avg point and p(high mean)
load([pwd() '\sub_final\sub_final_free_curvatures_Xfit']);
load("global_variables.mat")

% free curvatures v_names and v_symbols
v_symbol =  [v_symbol(3:6);{'\eta_{+}', '\eta_{-}'}'];
v_names = [v_names(3:6); {'curvature for gains', 'curvature for losses'}'];
plot_correlation_matrix_Xfit_v2(sub, Xfit, v_symbol, v_names, 'sub_final', 'free_curvatures', true, pwd)

%% Appendix B Individual Choice Curves Based on Observed and Simulated Data for 25 Participants
% individual choice curves for 25 subjects
load([fundir '\sub_final\sub_final_free_curvatures_sim.mat'])

figure(7); clf;
set(gcf, 'position', [200 200 1000 800]);

nx = 5;
ny = 5;
wg = ones(nx+1,1)*0.03;  % Reduced width gap between subplots
hg = ones(ny+1,1)*0.02;  % Reduced height gap between subplots
hg(1) = 0.07;  % Adjusted first row's height gap
wg(1) = 0.07;  % Adjusted first column's width gap

[ax, ~, ~, ax2] = easy_gridOfEqualFigures(hg, wg);
clear e
e = nan(1, length(ax));
e1 = nan(1, length(ax));

idx = [9    16    22    28    35    39    42    52 55    67    71    75    77    91    93    98  105   114   116   123   124   126   127   135  136   138   142   152   155   160   162   170];
for sn = 1:length(ax)
    e(sn) = plot_singleChoiceCurve_v1(ax(sn), sub(idx(sn)), UCFgold); % behavior
    hold on
    e1(sn) = plot_singleChoiceCurve_v1(ax(sn), sim(idx(sn)), UCFblack); % simulation
    
    xlabel('')
    ylabel('')
    % remove xtick and ytick labels
    if sn < 21
        set(gca, 'XTickLabel', [])
    end
    if mod(sn,5) ~= 1
        set(gca, 'YTickLabel', [])
    end
    legend('behavior','simulation', 'Location','southeast', 'FontSize',6) 
    
end
% set(e, 'linewidth', 1)
axes(ax(end-2)); xlabel('mean reward - offer','FontSize',16) 
axes(ax2(3,1)); ylabel('p(chose deck)','FontSize',16)
set(ax, 'tickdir', 'out')

