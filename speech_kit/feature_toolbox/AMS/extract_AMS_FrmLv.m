function [ns_ams] = extract_AMS_FrmLv(mix,freq)

if nargin < 2
    freq = 16000;
end

Srate = freq;
x = mix;
%% 
% Level Adjustment
[x ratio]= LTLAdjust(x, Srate);

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
% ns_ams = zeros(nChnl*15,KK);
%true_SNR = zeros(nChnl,KK);
ns_ams = zeros(15,KK);

parameters = AMS_init_FFT(nFFT_env,nFFT_speech,nFFT_ams,64,Srate);
% parameters_FB = AMS_init(nFFT_speech,64,64,Srate);

% ENV_x = env_extraction_gmt(X_sub, parameters_FB); %time domain envelope in subbands

ENV_x = decimate(abs(x),4,'fir');
mix_env = ENV_x;

win_ams = window(@hann,AMS_frame_len);
% repwin_ams = repmat(win_ams,1,nChnl);
repwin_ams = win_ams;
for kk=1:KK
    if kk == 1 %special treatment to the 1st frame, making it consistent with cochleagram and IBM calculation 
        mix_env_frm = mix_env((1:AMS_frame_step)+(AMS_frame_step*(kk-1)));
        ams = abs(fft(mix_env_frm.*repwin_ams((Srate/len2*s_frame_len/1000/2+1):end,:),nFFT_ams));        
    else
        mix_env_frm = mix_env((1:AMS_frame_len)+(AMS_frame_step*(kk-2)));    
        ams = abs(fft(mix_env_frm.*repwin_ams,nFFT_ams));        
    end
	ams = parameters.MF_T*ams(1:nFFT_ams/2);	
	ns_ams(:,kk) = ams;	
end

%%
return;

