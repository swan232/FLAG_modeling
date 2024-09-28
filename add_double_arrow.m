function [xstart1, xend1, xstar2, xend2, yend] = add_double_arrow(ax_pos, xl, yl, b)
        
        x0 = ax_pos(1);
        y0 = ax_pos(2);
        w = ax_pos(3);
        h = ax_pos(4);
        x1 = x0 + w;
        y1 = y0 + h;
        
        xmin = xl(1);
        xmax = xl(2);
        ymin = yl(1);
        ymax = yl(2);

        xs = rescale([xmin b b xmax], x0, x1);
        xstart1 = xs(1);
        xend1 = xs(2);
        xstart2 = xs(3);
        xend2 = xs(4);

        ys = rescale([ymin ymax], y0, y1);
        yend = ys(2);
        
        annotation('doublearrow', [xstart1 xend1], [yend yend], 'Color', 'black'); % Adjust coordinates
        annotation('doublearrow', [xstart2 xend2], [yend yend], 'Color', 'black'); % Adjust coordinates