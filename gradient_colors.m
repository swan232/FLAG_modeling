function gradientColors = gradient_colors(color1, color2, numColors)
% Generate gradient colors
gradientColors = zeros(numColors, 3); % Initialize the color matrix
for i = 1:3
    gradientColors(:, i) = linspace(color1(i),  color2(i), numColors);
end

