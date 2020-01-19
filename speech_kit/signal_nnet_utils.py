import numpy
import keras
import math
import keras.backend as K
import theano.tensor as T

from keras.layers import Input, Lambda, merge

def window(w, n):
	w = w + list(reversed(w))
	w = numpy.asarray(w)
	layer = Lambda(lambda x: x * w)
	layer.build((n,))
	return layer

def hann(n):
	w = [0.5 - 0.5*math.cos(2*math.pi*x) for x in  [t / float(n-1) for t in range(0, n/2)]]
	return window(w, n)

def hamming(n):
	w = [0.54 - 0.46*math.cos(2*math.pi*x) for x in  [t / float(n-1) for t in range(0, n/2)]]
	return window(w, n)

def blackman(n):
	w = [0.42 - 0.5*math.cos(2*math.pi*x) + 0.08*math.cos(4*math.pi*x) for x in  [t / float(n-1) for t in range(0, n/2)]]
	w[0] = 0
	return window(w, n)

def istft(x_re, x_im, n=320):
	def pad_symtx(x, alpha, n):
		idx = T.arange(n-1,0,-1)
		return K.concatenate([alpha * x, x.take(idx, axis=1)], axis=1)

	fftmtx = numpy.fft.ifft(numpy.eye(n))
	fr = numpy.real(fftmtx)
	fi = numpy.imag(fftmtx)

	ifft = lambda xr, xi: pad_symtx(xr, 1, n/2).dot(fr) - pad_symtx(xi, -1, n/2).dot(fi)

	return merge([x_re, x_im], mode=lambda v: ifft(v[0], v[1]), output_shape=lambda v:(v[0][0],n))


def stft(x, n=320):
	fftmtx = numpy.fft.fft(numpy.eye(n))
	fr = numpy.real(fftmtx)
	fi = numpy.imag(fftmtx)

	return (Lambda(lambda x: x.dot(fr)[:, :n/2+1])(x), Lambda(lambda x: -x.dot(fi)[:, :n/2+1])(x))


def abs_pahase2complex(abs_val, phase_val):
	re_val = merge([abs_val, phase_val], mode=lambda v: v[0] * numpy.cos(v[1]),  output_shape=lambda v:v[0])
	im_val = merge([abs_val, phase_val], mode=lambda v: v[0] * numpy.sin(v[1]),  output_shape=lambda v:v[0])
	return (re_val, im_val)


def apply_mask(spec, mask):
	return merge([spec, mask], mode='mul')

