function e = mse(x, y)
e = mean(mean((x-y).^2));