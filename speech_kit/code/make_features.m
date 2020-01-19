% Code to extract complementary features, which includes Amplitude
% Modulation Spectrogram (AMS), RASTA-PLP, MFCC, and Gammatone Filterbank
% Enegery (GF)

% These features can be extracted either at frame or subband level by
% feeding proper signal
%%
function feat_stack = make_features(signal, fs)
    signal = signal(:);
    
    feat_stack = [];
    % AMS
    nChnl = 64; % number of analysis channel
    ams = get_ams(signal, nChnl, fs);
    feat_stack = [feat_stack ams];
    nFrame = size(ams, 1);

    % RASTA-PLP
    lp_order = 12; % linear prediction order. The PLP dim = lp_order+1
    rastaplp_cep = rastaplp(signal, fs, 1, lp_order);
    feat_stack = [feat_stack rastaplp_cep(:,1:nFrame)'];

    % MFCC
    num_mel_fbank = 64; % number of analysis mel filterbank
    num_cep = 31; % number of cepstral coefs (mfcc dimension)
    mfcc = melfcc(signal, fs, 'numcep', num_cep, 'nbands', num_mel_fbank);
    feat_stack = [feat_stack mfcc(:,1:nFrame)'];

    % GF
%     num_gf = 64; % dimension of GF
%     gf = cochleagram(gammatone(signal, num_gf, [50, fs/2], fs))';
%     gf = gf(1:nFrame, :);
%     root = 1/15; % coef for root compression
%     gf = single(gf.^root);
%     feat_stack = [feat_stack gf];
    
    % remove bad elements due to silence
    feat_stack(isnan(feat_stack)) = 0;
    feat_stack(isinf(feat_stack)) = 0;
    
    
    