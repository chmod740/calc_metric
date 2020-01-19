function x_norm = monauralfeature(signal,fs)
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
    x_norm = meanVarArmaNormalize(comp_feat, arma_order);
    x_norm = single(x_norm);