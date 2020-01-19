import numpy
def zscore(X, m=None, s=None, in_place=False, limit_memory=False):
	if (m is not None) and (s is not None):
		if in_place:
			for i in range(X.shape[0]):
				for j in range(X.shape[1]):
					X[i, j] = (X[i, j] - m[j]) / s[j]
			return (X, m, s)
		return ((X - m)/s, m, s)
	if limit_memory:
		m, s = compute_mean_std_limit_space(X)
	else:
		m = numpy.mean(X, axis=0)
		s = numpy.std(X, axis=0)
	return zscore(X, m, s, in_place)

def compute_mean_std_limit_space(X):
	m = numpy.mean(X, axis=0)
	s = numpy.zeros_like(m)

	for j in range(X.shape[1]):
		for i in range(X.shape[0]):
			s[j] += (X[i,j] - m[j]) ** 2
		s[j] /= X.shape[0]
	s = numpy.sqrt(s)

	return (m, s)


# if __name__ == '__main__':
# 	t = [[0.8147, 0.1576, 0.6557, 0.7060],
# 		[0.9058, 0.9706, 0.0357, 0.0318],
# 		[0.1270, 0.9572, 0.8491, 0.2769],
# 		[0.9134, 0.4854, 0.9340, 0.0462],
# 		[0.6324, 0.8003, 0.6787, 0.0971],
# 		[0.0975, 0.1419, 0.7577, 0.8235],
# 		[0.2785, 0.4218, 0.7431, 0.6948],
# 		[0.5469, 0.9157, 0.3922, 0.3171],
# 		[0.9575, 0.7922, 0.6555, 0.9502],
# 		[0.9649, 0.9595, 0.1712, 0.0344]]
# 	t = numpy.asarray(t)

# 	X, m, s = zscore(t)
# 	print X
# 	print m
# 	print s

# 	# X, m, s = zscore(t, in_place=True)
# 	# print X
# 	# print m
# 	# print s

# 	X, m, s = zscore(t, limit_memory=True)
# 	print X
# 	print m
# 	print s

# 	# X, m, s = zscore(t, in_place=True, limit_memory=True)
# 	# print X
# 	# print m
# 	# print s
