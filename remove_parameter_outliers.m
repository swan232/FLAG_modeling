function matrix_trimmed = remove_parameter_outliers(matrix)
% Calculate mean and standard deviation for each row
row_means = mean(matrix, 2);
row_stds = std(matrix, 0, 2);

% Identify outliers
outliers = abs(matrix - row_means) > 3 * row_stds;

% Replace outliers with NaN
matrix(outliers) = NaN;

matrix_trimmed = matrix;
end
