function y = ibm(stft_speech, stft_noise)
y = abs(stft_speech) > abs(stft_noise);