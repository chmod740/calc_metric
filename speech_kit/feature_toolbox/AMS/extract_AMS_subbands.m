function X_sub = extract_AMS_subbands(mix, nChnl, freq)

% 
if nargin < 3
    freq = 16000;
end

% cl = cl ./ 2^15;
% tn = tn ./ 2^15;

Srate = freq;
x = mix;
%% 
% Level Adjustment
[x ratio]= LTLAdjust(x, Srate);
%tn = tn*ratio;
%cl = cl*ratio;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-emphasis for speech signal, which sharpens peaks and valleys
% cl = filter([1.5 -0.45],1,cl);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
len = floor(6*Srate/1000); % 6ms, frame size in samples, envelope length
if rem(len,2)==1
    len = len+1; 
end
%env_step = 0.25; % 1.00ms or 0.25ms, advance size, envelope step
env_step = 0.25;
len2 = floor(env_step*Srate/1000); 
%Nframes = floor(length(x)/len2)-len/len2+1;
Nframes = floor(length(x)/len2);
Srate_env = 1/(env_step/1000); % Since we calculate the envelope every 0.25ms, the sampling rate for envelope is this.
% win = hanning(len);
win = window(@hann,len);
%s_frame_len = 32; %32ms/frame
s_frame_len = 20;


nFFT_env = 128;
nFFT_ams = 256;

nFFT_speech = s_frame_len/1000*Srate; % in samples
AMS_frame_len = s_frame_len/env_step; % 128 frames of envelope corresponding to 128*0.25 = 32ms
AMS_frame_step = AMS_frame_len/2; % step size

k = 1;% sample position of the speech signal
kk = 1;
%KK = floor(Nframes/AMS_frame_step) - (AMS_frame_len/AMS_frame_step-1);
KK = floor(Nframes/AMS_frame_step);
ss = 1; % sample position of the noisy speech for synthesize
ns_ams = zeros(nChnl*15,KK);
%true_SNR = zeros(nChnl,KK);

parameters = AMS_init_FFT(nFFT_env,nFFT_speech,nFFT_ams,nChnl,Srate);
parameters_FB = AMS_init(nFFT_speech,64,nChnl,Srate);

X_sub = FB_filter(x, parameters_FB); % time domain signals in subbands


%%
return;

