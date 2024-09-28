function plot_choiceCurves_v2(sub, data_name, model_name, fig_save_dir, varargin)
UCFblack = [0, 0, 0];
UCFgold  = [255, 202, 6]/256;
% set the size of the figure
figure(3); clf;
set(gcf, 'position', [0, 100, 600, 400])

e1 = plot_choiceCurves_v1(gca, sub);

if nargin > 4 
    % number of models to plot
    num_models = varargin{1}; % 1 (full or alternative) or 2 (full and alternative)
    if num_models == 1
        
        % sub, data_name, model_name, fig_save_dir, and sim_full
        % plot observed vs. sim_full(or alternative)
        % unpack input arguments
        sim = varargin{2};
        e2 = plot_choiceCurveProbs_v1(gca, sim);
        set(e2, 'color', UCFblack)
        ylim([0 1])
        xline(0, '--k','LineWidth',2)
        yline(0.5,'--k','LineWidth',2)
        legend('behavior','simulation', 'Location','southeast', 'FontSize',16) 
        xlabel('mean reward - offer')
        ylabel('p(chose deck)')
        yticks([0, .5, 1])

    elseif num_models == 2
        % set the size of the figure
        set(gcf, 'Position', [100, 100, 1200, 800]); % Adjust the size as needed
        % plot observed vs. sim_full vs. sim_alternative
        % unpack input arguments
        sim_full = varargin{2};
        sim_alternative = varargin{3};
    
        e2 = plot_choiceCurveProbs_v1(gca, sim_full);
        set(e2, 'color', AZblue)
        e3 = plot_choiceCurveProbs_v1(gca, sim_alternative);
        set(e3, 'color', AZcactus)
        ylim([0 1])
        legend('behavior', ...
        'full model', ...
        [model_name ' model'], ...
        'Interpreter', 'none', ... 
        'Location','southeast')
    end
    

end
