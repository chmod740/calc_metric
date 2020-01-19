import h5py
import json


# repeat_vector

def get_activation(name):
	if name == 'linear':
		return ''
	if name == 'softmax':
		return 'nnet_softmax'
	return name


def load_param(name, params):
	if type(params) is not list:
		params = [params]
	template = "{params} = h5read(weight, '/model_weights/{name}/{params}');\n{params} = permute({params}, length(size({params})):-1:1);"
	return '\n'.join([template.format(name=name, params=p) for p in params])


def make_layer(cfg):
	layer_type = cfg['class_name']
	inputs = cfg['inbound_nodes']
	if len(inputs)>0:
		x = [x[0] for x in inputs[0]]

	cfg = cfg['config']
	name = cfg['name']
	
	if layer_type in ['InputLayer', 'ActivityRegularization']:
		return ("", "") # do nothing
	if layer_type == 'Mask':
		# TODO Implements it, while it is not used now.
		return ("", "error('unimplement layer type %s')"%layer_type)
	if layer_type in ['Dropout', 'SpatialDropout2D', 'SpatialDropout3D']:
		return ("", "{y} = {x};".format(y=name, x=x[0]))
	if layer_type == 'Activation':
		activation = get_activation(cfg['activation'])
		return ("", "{y} = {f}({x});".format(y=name, f=activation, x=x[0]))
	if layer_type == 'Reshape':
		tgt = ','.join([str(x) for x in cfg['target_shape']])
		return ("", "{y} = reshape({x}, [size({x},1), {tgt}]); % untested".format(y=name, x=x[0], tgt=tgt))
	if layer_type == 'Permute':
		tgt = ','.join([str(x+1) for x in cfg['dims']])
		return ("", "{y} = permute({x}, [1, {tgt}]); % untested".format(y=name, x=x[0], tgt=tgt))
	if layer_type == 'Flatten':
		return ("", "{y} = reshape({x}, [size({x},1),numel({x})/size({x},1)]); %untested".format(y=name, x=x[0]))
	if layer_type == 'RepeatVector':
		return ("", "{y} = repeat_vector({x}, {n}); %untested".format(y=name, x=x[0], n=str(cfg['n'])))
	if layer_type == 'Lambda':
		# TODO Check the implements. There may be some thing to do by hard code
		return ("", "error('unimplement layer type %s')"%layer_type)
	if layer_type == 'Dense':
		w = name + '_W'
		b = name + '_b'
		activation = get_activation(cfg['activation'])
		if cfg['bias']:
			return (load_param(name, [w, b]), "{y} = {f}(bsxfun(@plus, {x}*{w}, {b}));".format(y=name, f=activation, x=x[0], w=w, b=b))
		else:
			return (load_param(name, w), "{y} = {f}({x}*{w});".format(y=name, f=activation, x=x[0], w=w))
	if layer_type == 'MaxoutDense':
		w = name + '_W'
		b = name + '_b'
		if cfg['bias']:
			return (load_param(name, [w, b]), "{y} = max(bsxfun(@plus, {x}*{w}, {b}), 2);".format(y=name, x=x[0], w=w, b=b))
		else:
			return (load_param(name, w), "{y} = max({x}*{w}, 2);".format(y=name, x=x[0], w=w))
	if layer_type == 'Highway':
		w = name + '_W'
		b = name + '_b'
		w_c = W + '_carry'
		b_c = b + '_carry'
		activation = get_activation(cfg['activation'])
		if cfg['bias']:
			cmd = "tmp_w = sigmoid(bsxfun(@plus, {x}*{w_c}, {b_c}));\n" \
				+ "tmp_a = {f}(bsxfun(@plus, {x}*{w}, {b})) .* tmp_w;" \
				+ "{y} = tmp_a + (1-tmp_w).*{x};"
			cmd = cmd.format(y=name, x=x[0], w=w, w_c=w_c, b=b, b_c=b_c)
			return (load_param(name, [w, b, w_c, b_c]), cmd)
		else:
			cmd = "tmp_w = sigmoid({x}*{w_c});\n" \
				+ "tmp_a = {f}({x}*{w}) .* tmp_w;" \
				+ "{y} = tmp_a + (1-tmp_w).*{x};"
			cmd = cmd.format(y=name, x=x[0], w=w, w_c=w_c)
			return (load_param(name, [w, w_c]), cmd)
	if layer_type == 'TimeDistributedDense':
		# TODO Check implements
		return ("", "error('unimplement layer type %s')"%layer_type)
	if layer_type == 'LeakyReLU':
		p = cfg['alpha']
		return ("", "{y} = relu({x}, {p});".format(y=name, x=x[0], p=p))
	if layer_type == 'PReLU':
		return (load_param(name, name+'_alphas'),
				"{y} = relu({x}) + {y}_alphas .* ({x} - abs({x})) * 0.5;".format(y=name, x=x[0]))
	if layer_type == 'ELU':
		p = cfg['alpha']
		return ("", "%s = elu(%s, %f);"%(name, x[0], p))
	if layer_type == 'ParametricSoftplus':
		alpha, beta = (name + '_alphas', name + '_betas')
		return (load_param(name, [alpha, beta]), 
				"{y} = softplus({beta} .* {x}) .* {alpha});".format(y=name, x=x[0], alpha=alpha, bate=bate))
	if layer_type == 'ThresholdedReLU':
		return ("", "{y} = {x} .* ({x} > {theta})".format(y=name, x=x[0], theta=cfg['theta']))
	if layer_type == 'SReLU':
		t_left = name + '_t_left'
		a_left = name + '_a_left'
		t_right = name + '_t_right'
		a_right = name + '_a_right'
		cmd = 't_right_actual = {t_left} + abs({t_right});\n'.format(t_left=t_left, t_right=t_right)
		cmd += 'Y_left_and_center = {t_left} + relu({x} - {t_left}, {a_left}, t_right_actual - {t_left});\n'.format(x=x[0], a_left=a_left, t_left=t_left)
		cmd += 'Y_right = relu({x} - t_right_actual) .* {a_right};\n'.format(x=x[0], a_right=a_right)
		cmd += '{y} = Y_left_and_center + Y_right;'.format(y=name)
		return (load_param(name, [t_right, t_left, a_right, a_left]), cmd)
	if layer_type in ['Convolution1D', 'AtrousConvolution1D']:
		activation = get_activation(cfg['activation'])
		border_mode = cfg['border_mode']
		bias = cfg['bias']
		if 'atrous_rate' in cfg:
			atrous_rate = cfg['atrous_rate']
		else:
			atrous_rate = "(1, 1)"
		w = name + '_W'
		b = name + '_b'
		if bias:
			params = load_param(name, [w, b])
		else:
			params = load_param(name, w)
		return (load_param(name, [w, b]), 
			"{y} = {f}(convolution1d({x}, {w}, {b}, {border_mode}, {atrous_rate}));".format(y=name, f=activation, x=x[0], w=w, b=b, border_mode="'%s'"%border_mode, atrous_rate=atrous_rate))
	if layer_type in ['Convolution2D', 'AtrousConvolution2D']:
		activation = get_activation(cfg['activation'])
		border_mode = cfg['border_mode']
		bias = cfg['bias']
		if 'atrous_rate' in cfg:
			atrous_rate = cfg['atrous_rate']
		else:
			atrous_rate = "(1, 1)"
		w = name + '_W'
		b = name + '_b'
		if bias:
			params = load_param(name, [w, b])
		else:
			params = load_param(name, w)
		return (load_param(name, [w, b]), 
			"{y} = {f}(convolution2d({x}, {w}, {b}, {border_mode}, {atrous_rate}));".format(y=name, f=activation, x=x[0], w=w, b=b, border_mode="'%s'"%border_mode, atrous_rate=atrous_rate))


	

def keras2matlab(config, model_name=None):
	name = config['name']
	inputs = [x[0] for x in config['input_layers']]
	outputs = [x[0] for x in config['output_layers']]
	layers = [make_layer(l) for l in config['layers']]
	f = open('%s.m'%(model_name if model_name is not None else name),'w')
	print >>f, 'function [%s] = %s(weight, %s)'%(', '.join(outputs), name, ', '.join(inputs))
	for t in layers:
		print >>f, t[0]

	for t in layers:
		print >>f, t[1]



if __name__ == '__main__':
	f = h5py.File('model_epoch_199.h5', 'r')
	model_config = f.attrs.get('model_config')
	f.close()
	model_config = json.loads(model_config.decode('utf-8'))['config']
	# print model_config
	keras2matlab(model_config)