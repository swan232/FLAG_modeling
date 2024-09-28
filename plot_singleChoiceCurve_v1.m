function e = plot_singleChoiceCurve_v1(ax, sub,color)

global UCFgold

R = [sub.game.rewards];
O = [sub.game.offer];
C = [sub.game.choseDeck];

% difference between mean reward and offer
D = mean(R, 'omitmissing') - O; 
% D = R(1,:)-O;
binEdges = -200:50:200;
% binIt returns binMeans, binContents, binCentres, binSem
[m, ~, x, s] = binIt(D, C, binEdges, 'beta');

axes(ax); hold on;
e = errorbar(x, m, s, 'Color', color);

xlim([-300, 300]);
xticks([-300 0 300]);
xtickangle(0)

xlabel('mean reward - offer')
ylabel('p(chose deck)')
ylim([0 1])

