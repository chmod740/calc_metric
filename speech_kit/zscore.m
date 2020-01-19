function [y, m, s] = zscore(x, m, s)

if nargin < 2
	m = mean(x);
	s = std(x);
end

y = bsxfun(@rdivide, bsxfun(@minus, x, m), s);
