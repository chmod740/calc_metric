function y = relu(x, p, max_value)
	if nargin == 1
		y = (x + abs(x)) / 2;
	else
		f1 = 0.5 * (1 + p);
        f2 = 0.5 * (1 - p);
        y = f1 * x + f2 * abs(x);
    end
    if nargin > 2
    	y = min(y, max_value);
    end