function e = plot_choiceCurves_v1(ax, sub)
global UCFgold
global UCFblack


for sn = 1:length(sub)
    R = [sub(sn).game.rewards];
    O = [sub(sn).game.offer];
    C = [sub(sn).game.choseDeck];
    
    % difference between mean reward and offer
    D = mean(R, 'omitmissing') - O; 
    binEdges = -200:50:200;
    [m(sn,:), ~, x, s] = binIt(D, C, binEdges, 'beta');
end
size(m); 
x; 
s ;
M = nanmean(m);
S = nanstd(m) / sqrt(size(m,1));

axes(ax); hold on;

if nargin < 3
    e = errorbar(x, M, S);
    set(e, 'color', [255, 202, 6]/256, 'linewidth', 3, 'marker', '.', 'markersize', 50)
end
xlim([-300 300])
xlabel('mean reward - offer')
ylabel('p(chose deck)')
yticks([0, .5, 1])
