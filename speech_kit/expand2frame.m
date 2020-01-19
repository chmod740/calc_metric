function D = expand2frame(raw, winsize)
[r, c] = size(raw);
D = zeros(r, c*(2*winsize+1));
s = 0;
for i=-winsize:winsize
	t = circshift(raw, i);
	D(:,s*c+1:(s+1)*c) = t;
	s = s + 1;
end