function y = elu(x, p)
	if nargin<1
		p = 1;
	end
	if x > 0
		y = x;
	else
		y = p * (exp(x) - 1));
	end