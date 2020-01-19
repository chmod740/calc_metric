function [mix_stoi, mix_pesq, mix_snr, mix_sdr, est_stoi, est_pesq, est_snr, est_sdr] = test_metric(clean_wav_file, mix_wav_file, est_wav_file)
  [wave_clean, clean_fs] = audioread(clean_wav_file);
  [wave_mix, mix_fs] = audioread(mix_wav_file);
  [wave_est, est_fs] = audioread(est_wav_file);
  
  wave_clean_length = length(wave_clean);
  wave_mix_length = length(wave_mix);
  wave_est_length = length(wave_est);
  wave_min_length = min(wave_mix_length, wave_est_length);
  
  mix_stoi = stoi(wave_clean(1:wave_min_length), wave_mix(1:wave_min_length), 16e3);
  mix_pesq = pesq(wave_clean(1:wave_min_length), wave_mix(1:wave_min_length), 16e3);
  mix_snr = snr(wave_mix(1:wave_min_length), wave_clean(1:wave_min_length));
  [mix_sdr, mix_i, mix_a] = bss_eval_sources(wave_mix(1:wave_min_length)', wave_clean(1:wave_min_length)');
  
  est_stoi = stoi(wave_clean(1:wave_min_length), wave_est(1:wave_min_length), 16e3);
  est_pesq = pesq(wave_clean(1:wave_min_length), wave_est(1:wave_min_length), 16e3);
  est_snr = snr(wave_est(1:wave_min_length), wave_clean(1:wave_min_length));
  [est_sdr, est_i, est_a] = bss_eval_sources(wave_est(1:wave_min_length)', wave_clean(1:wave_min_length)');
  
  %fprintf('mix stoi: %d \n', mix_stoi); 
  %printf('mix pesq: %d \n', mix_pesq); 
  %fprintf('mix snr: %d \n', mix_snr);
  %fprintf('mix sdr: %d \n', mix_sdr);
  
  %fprintf('est stoi: %d \n', est_stoi); 
  %fprintf('est pesq: %d \n', est_pesq); 
  %fprintf('est snr: %d \n', est_snr);
  %fprintf('est sdr: %d \n', est_sdr);

end

