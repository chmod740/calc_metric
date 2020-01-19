function o = frame2wav(est, f, w, h)
if nargin < 2
	f = 320;
end
if nargin < 3
	w = f;
end
if nargin < 4
	h = w/2;
end

o = zeros(size(est,2)*w+h,1);
for i=1:size(est,2)-1
    o((i-1)*h+1:(i-1)*h+w) = o((i-1)*h+1:(i-1)*h+w)+ est(:,i);
end