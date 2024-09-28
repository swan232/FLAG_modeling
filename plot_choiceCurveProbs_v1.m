function e = plot_choiceCurveProbs_v1(ax, sub)
global UCFgold

for sn = 1:length(sub)
    R = [sub(sn).game.rewards];
    O = [sub(sn).game.offer];
    C = [sub(sn).game.pDeck];
    
    % difference between mean reward and offer
    D = mean(R) - O;  
    binEdges = [-200:50:200];
    [m(sn,:), ~, x, s] = binIt(D, C, binEdges, 'beta');
end

M = nanmean(m);
S = nanstd(m) / sqrt(size(m,1));

axes(ax); hold on;
e = errorbar(x, M, S);
set(e, 'color', UCFgold, 'linewidth', 3, ...
    'marker', '.', 'markersize', 50)
xlabel('mean reward - offer')
ylabel('p(chose deck)')
ylabel('probability choosing deck')