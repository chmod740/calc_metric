function t = quantization(x)
	u = 255;
	y = sign(x).*log(1+u.*abs(x))./(log(1+u));
	t = round(y*127)+128;