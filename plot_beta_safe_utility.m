function p = plot_beta_safe_utility(gradientColors,linewidth)

delta = -300:1:300;
beta_safes = -2:1:1;
beta_offer = 0.02;
    
n_beta_safe = length(beta_safes);
nrow = ceil(sqrt(n_beta_safe));
ncol = ceil(n_beta_safe / nrow);
for i = 1:n_beta_safe
    beta_safe = beta_safes(i);
    p_left = beta_safe_beta_offer_utility(beta_safe, beta_offer, delta);
    plot(delta, p_left, 'Color', gradientColors(i,:),'LineWidth',linewidth);
    xlim([-300 300])
    xticks([-300 0 300])
    yticks([0, .5, 1])
    xticklabels({'-300','0','300'})
    xlabel('R_{deck} - R_{offer}')
    ylabel('p(chose deck)')
    title({'choice curve as a function', 'of safe bias'})
    set(gca, 'box', 'off')
    hold on;
end

xline(0, '--k','LineWidth',2)
yline(0.5,'--k','LineWidth',2)

legend(arrayfun(@(beta_safe) ['\beta_{safe} = ' num2str(beta_safe)], beta_safes, 'UniformOutput', false), 'Location','southoutside','Orientation','horizontal', 'NumColumns', 2)


ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

