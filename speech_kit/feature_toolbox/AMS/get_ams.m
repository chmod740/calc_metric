function AMS_points = get_ams(signal, nChan, fs)

% frame_shift = 10ms
nFrame = floor(length(signal)/fs*100) - 1;
AMS_points = extract_AMS(signal,nChan, fs)';
AMS_points = AMS_points(1:nFrame,:);
