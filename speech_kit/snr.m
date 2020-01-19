function r = snr(data, ref)
r = 0;
ps = (ref - mean(ref(:))).^2;
ps = sum(ps(:));
pn = (data-ref).^2;
pn = sum(pn(:));
r = 10*log10(ps/pn);