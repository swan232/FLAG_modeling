function p = plot_beta_r_utility(gradientColors, linewidth)
delta = -300:1:300;
beta_safe = 0;
beta_offers = -0.02:.02:0.04;
   
n_beta_offer = length(beta_offers);
nrow = 2;
ncol = n_beta_offer / 2;
for i = 1:n_beta_offer
    beta_offer = beta_offers(i);
    p_left = beta_safe_beta_offer_utility(beta_safe, beta_offer, delta);
    plot(delta, p_left, 'Color', gradientColors(i,:), 'LineWidth', linewidth)
    xlim([-300 300])
    xticks([-300 0 300])
    xticklabels({'-300','0','300'})
    yticks([0, .5, 1])

    xlabel('R_{deck} - R_{offer}')
    ylabel('p(chose deck)')
    title({'choice curve as a function ', 'of inverse temperature'})
    set(gca,'box','off')
    hold on;
end
xline(0.5,'--k','LineWidth',2)
legend(arrayfun(@(beta_offer) ['\beta_{r} = ' num2str(beta_offer)], beta_offers, 'UniformOutput', false), 'Location','southoutside', 'Orientation','horizontal', 'NumColumns', 2)

ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;


