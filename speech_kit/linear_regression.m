function w = linear_regression(X, Y, sigmoid, with_bias)

if nargin < 4
	with_bias = 1;
end
if nargin < 3
	sigmoid = 0;
end

if with_bias
	X = [ones(size(X, 1), 1), X];
end

if sigmoid
	Y = Y .* 10 - 5;
end

w = geninv(X) * Y;

