function y = irm(stft_speech, stft_noise)
y = sqrt(abs(stft_speech).^2 ./ (abs(stft_speech).^2 + abs(stft_noise).^2));