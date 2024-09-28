function [sub_male, sub_female] = group_by_gender(sub)
    sub_male = sub([sub.gender1]==1); % length(sub_male) 75 
    disp(['number of males: ' num2str(length(sub_male))])
    sub_female=sub([sub.gender1]==0); % length(sub_female) 95
    disp(['number of females: ' num2str(length(sub_female))])