%%
clear all;
addpath(genpath('../feature_toolbox'))
%%
[signal, fs] = wavread('../signal/signal.wav');
%% get frame-level complementary feature

% frame-level
comp_feat = make_features(signal, fs);

% append delta feature
delta_order = 9;
if delta_order > 0
    delta = deltas(comp_feat, delta_order);
    comp_feat = [comp_feat delta];
end

% if needed, can do mean-variance normalization + ARMA post-processing
arma_order = 2;
[x_norm, x_mean, x_std] = meanVarArmaNormalize(comp_feat, arma_order);

% can do windowing
side_size = 2; % a 5-frame window
x_windowed = make_window_buffer(x_norm, side_size);
%% channel-level feature
chan_id = 11;
subbands = gammatone(signal, 64, [50, 8000], fs);
subband_signal = subbands(chan_id, :);
comp_feat_suband = make_features(subband_signal, fs);

% do stuff with comp_feat_subband...
