import h5py
import numpy
import theano
import struct


def load_data(fn, data):
	if type(data) not in [list, dict]:
		data = {data: []}
	if type(data) in [list]:
		data = {k:[] for k in data}

	file = h5py.File(fn, 'r')

	for k in data:
		data[k] = numpy.asarray(file[k][:], dtype=theano.config.floatX).T

	return data

def save_data(fn, data):
	file = h5py.File(fn, 'w')
	for k in data:
		file.create_dataset(k, data=data[k])
	file.close()

def load_raw_binary(file_name, size, dtype):
	res = numpy.zeros(size)
	if dtype == 'single':
		byte = 4
		fmt = 'f'
	else:
		byte = 8
		fmt = 'd'
	with open(file_name) as f:
		for idx in range(size[1]):
			data = f.read(size[0]*byte)
			res[:,idx] = numpy.asarray(struct.unpack('<'+(fmt*size[0]),data))
	return res


def load_raw_binary(file_name, size, dtype='single', offset=0):
	res = numpy.zeros(size)
	if dtype == 'single':
		byte = 4
		fmt = 'f'
	else:
		byte = 8
		fmt = 'd'
	with open(file_name) as f:
		f.seek(size[0]*byte*offset)
		for idx in range(size[1]):
			data = f.read(size[0]*byte)
			res[:,idx] = numpy.asarray(struct.unpack('<'+(fmt*size[0]),data))
	return res
