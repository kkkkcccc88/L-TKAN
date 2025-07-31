import numpy as np
from keras.initializers import Initializer
import keras.backend as K
import keras.layers as layers
import keras.activations as activations
import keras.ops as ops
from keras import layers, activations, initializers, regularizers, constraints

class GridInitializer(initializers.Initializer):
    """
    简化后的网格初始化器，用于生成指数径向基函数的中心点。
    """
    def __init__(self, grid_range, grid_size):
        self.grid_range = grid_range
        self.grid_size = grid_size

    def __call__(self, shape, dtype=None):
        grid = np.linspace(self.grid_range[0], self.grid_range[1], self.grid_size)
        grid = np.expand_dims(grid, 0)  # [1, grid_size]
        return np.tile(grid, [shape[0], 1])  # [in_features, grid_size]

    def get_config(self):
        return {
            "grid_range": self.grid_range,
            "grid_size": self.grid_size
        }

class KANLinear(layers.Layer):
    def __init__(
        self,
        units,
        grid_size=1,
        base_activation='relu',
        grid_range=[-1, 1],
        dropout=0.,
        use_bias=True,
        use_layernorm=True,
        # beta_initializer='ones',  # 添加 beta 的初始化器
        **kwargs
    ):
        super(KANLinear, self).__init__(**kwargs)
        self.units = units
        self.grid_size = grid_size
        self.base_activation_name = base_activation
        self.grid_range = grid_range
        self.use_bias = use_bias
        self.use_layernorm = use_layernorm
        self.dropout_rate = dropout
        self.beta_initializer=initializers.Constant(0.66)  # 将 beta 初始化为 0.5

    def build(self, input_shape):
        self.in_features = input_shape[-1]
        
        # 初始化指数径向基函数的中心点
        self.centers = self.add_weight(
            name="centers",
            shape=(self.in_features, self.grid_size),
            initializer=GridInitializer(self.grid_range, self.grid_size),
            trainable=False,  # 中心点可以设置为不可训练
        )
        
        # 初始化 beta 为可训练权重
        self.beta = self.add_weight(
            name="beta",
            shape=(self.in_features, self.grid_size),
            initializer=self.beta_initializer,  # 使用指定的初始化器
            trainable=False,  # 可训练的 beta
        )
        
        self.base_weight = self.add_weight(
            name="base_weight",
            shape=(self.in_features, self.units),
            initializer='glorot_uniform',
        )
        if self.use_bias:
            self.base_bias = self.add_weight(
                name="base_bias",
                shape=(self.units,),
                initializer="zeros",
            )
        self.rbf_weight = self.add_weight(
            name="rbf_weight",
            shape=(self.in_features * self.grid_size, self.units),
            initializer='glorot_uniform',
        )
        if self.use_layernorm:
            self.layer_norm = layers.LayerNormalization(axis=-1)
        self.dropout = layers.Dropout(self.dropout_rate)

    def call(self, x, training=None):
        if self.use_layernorm:
            x = self.layer_norm(x)

        # 基础激活函数部分
        base_activation = activations.get(self.base_activation_name)
        base_output = ops.matmul(base_activation(x), self.base_weight)
        if self.use_bias:
            base_output = ops.add(base_output, self.base_bias)

        # 指数径向基函数部分
        rbf_output = self.exponential_rbf(x)
        rbf_output = ops.matmul(rbf_output, self.rbf_weight)

        # 合并输出
        output = self.dropout(base_output, training=training) + self.dropout(rbf_output, training=training)
        return output

    def exponential_rbf(self, x):
        """
        指数径向基函数的实现
        """
        x_expanded = ops.expand_dims(x, -1)  # [batch_size, in_features, 1]
        centers_expanded = ops.expand_dims(self.centers, 0)  # [1, in_features, grid_size]
        distance = ops.abs(x_expanded - centers_expanded)  # [batch_size, in_features, grid_size]
        beta_expanded = ops.expand_dims(self.beta, 0)  # [1, in_features, grid_size]
        rbf_values = ops.exp(-beta_expanded * distance)  # 使用可训练的 beta
        return ops.reshape(rbf_values, [ops.shape(x)[0], -1])

    def compute_output_shape(self, input_shape):
        return input_shape[:-1] + (self.units,)

    def get_config(self):
        config = super(KANLinear, self).get_config()
        config.update({
            'units': self.units,
            'grid_size': self.grid_size,
            'base_activation': self.base_activation_name,
            'grid_range': self.grid_range,
            'dropout': self.dropout_rate,
            'use_bias': self.use_bias,
            'use_layernorm': self.use_layernorm,
            'beta_initializer': initializers.serialize(self.beta_initializer)
        })
        return config

    @classmethod
    def from_config(cls, config):
        return cls(**config)