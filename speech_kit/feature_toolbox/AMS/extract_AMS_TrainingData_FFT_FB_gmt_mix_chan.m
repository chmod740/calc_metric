function [ns_ams] = extract_AMS_TrainingData_FFT_FB_gmt_mix_chan(mix, ichan, nChnl , freq)
% filename: file name of waveform for extracting feature
% cl_file: file name of clean signal
% nChnl: # of channel (filterbank)

% Order of AMS = 15
% ns_ams: AMS (N x # of frames, N=Order of AMS x # of channel)
% true_SNR: true SNR (# of channel x # of frames)
%

%
% Yang Lu
% April, 2007
%
% This program is used to extract the AMS from a file as well as the SNRs 
% in subbands with high efficiency (frame by frame).


if nargin < 4
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
% ns_ams = zeros(nChnl*15,KK);
ns_ams = zeros(1*15,KK);
%true_SNR = zeros(nChnl,KK);

parameters = AMS_init_FFT(nFFT_env,nFFT_speech,nFFT_ams,nChnl,Srate);
parameters_FB = AMS_init(nFFT_speech,64,nChnl,Srate);

%X_sub = FB_filter(x, parameters_FB); % time domain signals in subbands
%TN_sub = FB_filter(tn, parameters_FB);
%CL_sub = FB_filter(cl, parameters_FB);
X_sub = gammatone(x, nChnl, [50 8000], Srate);
%TN_sub = gammatone(tn, nChnl, [50 8000], Srate);
%CL_sub = gammatone(cl, nChnl, [50 8000], Srate);

ENV_x = env_extraction_gmt_chan(X_sub, ichan,parameters_FB); %time domain envelope in subbands
%ENV_tn = env_extraction_gmt(TN_sub, parameters_FB);
%ENV_cl = env_extraction_gmt(CL_sub, parameters_FB);

mix_env = ENV_x;
%tn_env = ENV_tn;
%cl_env = ENV_cl;

win_ams = window(@hann,AMS_frame_len);
% repwin_ams = repmat(win_ams,1,nChnl);
repwin_ams = repmat(win_ams,1,1);
for kk=1:KK
    if kk == 1 %special treatment to the 1st frame, making it consistent with cochleagram and IBM calculation 
        mix_env_frm = mix_env(:,(1:AMS_frame_step)+(AMS_frame_step*(kk-1)));
        ams = abs(fft(mix_env_frm'.*repwin_ams((Srate/len2*s_frame_len/1000/2+1):end,:),nFFT_ams));
        
        %tn_env_frm = tn_env(:,(1:AMS_frame_step)+(AMS_frame_step*(kk-1)));
        %cl_env_frm = cl_env(:,(1:AMS_frame_step)+(AMS_frame_step*(kk-1)));        
    else
        mix_env_frm = mix_env(:,(1:AMS_frame_len)+(AMS_frame_step*(kk-2)));    
        ams = abs(fft(mix_env_frm'.*repwin_ams,nFFT_ams));
        
        %tn_env_frm = tn_env(:,(1:AMS_frame_len)+(AMS_frame_step*(kk-2)));
        %cl_env_frm = cl_env(:,(1:AMS_frame_len)+(AMS_frame_step*(kk-2)));        
    end
	ams = parameters.MF_T*ams(1:nFFT_ams/2,:);
	ams = ams';
	ns_ams(:,kk) = reshape(ams,[],1);
	
	%true_SNR(:,kk) = extract_SNR_envFrm(cl_env_frm.^2,tn_env_frm.^2,AMS_frame_len);% calculate SNR from envelope
end

%%
return;

