function [ax, hb, wb, ax2] = easy_gridOfEqualFigures(hg, wg, fignum)

 % if hg has N_high elements and wg has N_wide elements, then the total
 % number of subplots created will be (N_high - 1) * (N_wide -1)

% gridOfEqualFigures.m
% ax = gridOfEqualFigures(hg, wg, fignum)
% makes a grid of equally sized subplots with gaps between subplots given
% by hg and wg (in normalized units)
% example:
%   ax = easy_gridOfEqualFigures([0.1 0.1 0.1], [0.1 0.1 0.1]); 
% 

% Robert Wilson
% 23-Mar-2010

% hg
% wg

hb = (ones(length(hg)-1,1)-sum(hg)) / (length(hg)-1);
wb = (ones(length(wg)-1,1)-sum(wg)) / (length(wg)-1);


if exist('fignum')
    figure(fignum); %clf;
end
if nargin < 5
    fignum = gcf;
end

N_high = length(hg) - 1;
N_wide = length(wg) - 1;

count = 1;

for i_high = N_high:-1:1
    for i_wide = 1:N_wide
        
        bx(1) = sum(wg(1:i_wide)) + sum(wb(1:i_wide-1));
        bx(2) = sum(hg(1:i_high)) + sum(hb(1:i_high-1));
        bx(3) = wb(i_wide);
        bx(4) = hb(i_high);
        
        rc{count} = bx;
        count = count + 1;
    end
end



for i = 1:length(rc)
    axes('position', rc{i})
    ax(i) = gca;
end
% length(wb) % 3
% length(hb) % 1 
ax2 = reshape(ax, [length(wb) length(hb)])';