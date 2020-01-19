function x = wav2frame(x, f, w, h)
if nargin < 2
	f = 320;
end
if nargin < 3
	w = f;
end
if nargin < 4
	h = w/2;
end
if length(w) == 1
	w = hamming(w);
end

d = stft(x, f, w, h);
ft = [conj(d); d((f/2):-1:2, :)];
x = real(ifft(ft));

% Another method implement the IFFT, which is used as a reference for
% multipl-only architecture.
% x = real(conj(dftmtx(320))/320*(ft));
