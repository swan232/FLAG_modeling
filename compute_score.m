function sub = compute_score(sub)

for sn = 1:length(sub)
    sub(sn).score = sum([sub(sn).game.outcome]);
    sub(sn).mean_score = mean([sub(sn).game.outcome], "omitmissing"); 
end
