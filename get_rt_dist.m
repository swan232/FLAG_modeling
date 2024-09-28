% function [RT, RT5] = get_rt_dist(sub1)
function rt_dist = get_rt_dist(sub1)
    clearvars RT RT5
    for sn = 1:length(sub1)
        RT5(:,sn) = median([sub1(sn).game.rts]', "omitmissing"); 
        RT(:,sn) = mean([sub1(sn).game.rt], "omitmissing");
    end
    
    rt_dist.RT = RT;
    rt_dist.RT5 = RT5;
    rt_dist.mean_rt = mean(RT,2, "omitmissing")/1000;
    rt_dist.median_rt5 = median(RT5,2, "omitmissing")/1000;
    




