# -*- coding: utf-8 -*-
from __future__ import absolute_import

from keras import backend as K
from keras import activations, initializations, regularizers, constraints
from keras.engine import Layer, InputSpec
from keras.utils.np_utils import conv_output_length, conv_input_length
from keras.layers.convolutional import Convolution1D


class AtrousConvolution1D(Convolution1D):
    def __init__(self, nb_filter, filter_length,
                 init='uniform', activation='linear', weights=None,
                 border_mode='valid', subsample_length=1,
                 atrous_rate=1, W_regularizer=None, 
                 b_regularizer=None, activity_regularizer=None,
                 W_constraint=None, b_constraint=None,
                 bias=True, **kwargs):
        if border_mode not in {'valid', 'same'}:
            raise Exception('Invalid border mode for AtrousConv1D:', border_mode)

        self.atrous_rate = atrous_rate

        super(AtrousConvolution1D, self).__init__(nb_filter, filter_length,
                                                  init=init, activation=activation,
                                                  weights=weights, border_mode=border_mode,
                                                  subsample_length=subsample_length,
                                                  W_regularizer=W_regularizer, b_regularizer=b_regularizer,
                                                  activity_regularizer=activity_regularizer,
                                                  W_constraint=W_constraint, b_constraint=b_constraint,
                                                  bias=bias, **kwargs)

    def get_output_shape_for(self, input_shape):
        length = conv_output_length(input_shape[1],  self.filter_length, self.border_mode,
                                  self.subsample[0], dilation=self.atrous_rate)
        return (input_shape[0], length, self.nb_filter)

    def call(self, x, mask=None):
        x = K.expand_dims(x, -1)  # add a dimension of the right
        x = K.permute_dimensions(x, (0, 2, 1, 3))
        output = K.conv2d(x, self.W, strides=self.subsample,
                          border_mode=self.border_mode,
                          dim_ordering='th')
        if self.bias:
            output += K.reshape(self.b, (1, self.nb_filter, 1, 1))
        output = K.squeeze(output, 3)  # remove the dummy 3rd dimension
        output = K.permute_dimensions(output, (0, 2, 1))
        output = self.activation(output)
        return output


        output = K.conv2d(x, self.W, strides=self.subsample,
                          border_mode=self.border_mode,
                          dim_ordering='th',
                          filter_shape=self.W_shape,
                          filter_dilation=self.atrous_rate)
        if self.bias:
            output += K.reshape(self.b, (1, self.nb_filter, 1, 1))
        output = K.squeeze(output, 3)  # remove the dummy 3rd dimension
        output = K.permute_dimensions(output, (0, 2, 1))
        output = self.activation(output)
        return output

    def get_config(self):
        config = {'atrous_rate': self.atrous_rate}
        base_config = super(AtrousConvolution1D, self).get_config()
        return dict(list(base_config.items()) + list(config.items()))

