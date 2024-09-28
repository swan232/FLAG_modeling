function [M, SD, h, p, ci, stats] = paired_t_test_with_nan(x, y)

% Remove pairs where either value is NaN
validIdx = ~isnan(x) & ~isnan(y);  % Find indices where neither value is NaN

M = mean(x(validIdx) - y(validIdx));
SD = std(x(validIdx) - y(validIdx));

% Perform paired t-test on valid data
[h, p, ci, stats] = ttest(x(validIdx), y(validIdx));

% Display the result
fprintf('Paired t-test p-value: %.4f\n', p);