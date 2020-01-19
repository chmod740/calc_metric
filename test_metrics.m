function [] = test_metrics( index_file_path, out_file_path )
%MAIN Summary of this function goes here
%   Detailed explanation goes here
    fp = fopen(index_file_path, 'r');
    tline = fgetl(fp);
    sum_mix_stoi = 0;
    sum_mix_pesq = 0;
    sum_mix_snr = 0;
    sum_mix_sdr = 0;
    sum_est_stoi = 0;
    sum_est_pesq = 0;
    sum_est_snr = 0;
    sum_est_sdr = 0;
    count = 0;
    while tline ~= -1
        count = count + 1;
        S = strsplit(tline);
        % disp(S(1));
        S1 = char(S(1));
        S2 = char(S(2));
        S3 = char(S(3));
        
        [mix_stoi, mix_pesq, mix_snr, mix_sdr, est_stoi, est_pesq, est_snr, est_sdr] = test_metric(S1, S2, S3);
        sum_mix_stoi = sum_mix_stoi + mix_stoi;
        sum_mix_pesq = sum_mix_pesq + mix_pesq;
        sum_mix_snr = sum_mix_snr + mix_snr;
        sum_mix_sdr = sum_mix_sdr + mix_sdr;
        
        sum_est_stoi = sum_est_stoi + est_stoi;
        sum_est_pesq = sum_est_pesq + est_pesq;
        sum_est_snr = sum_est_snr + est_snr;
        sum_est_sdr = sum_est_sdr + est_sdr;
        tline = fgetl(fp);
    end
    fclose(fp);
    sum_mix_stoi = sum_mix_stoi / count;
    sum_mix_pesq = sum_mix_pesq / count;
    sum_mix_snr = sum_mix_snr / count;
    sum_mix_sdr = sum_mix_sdr / count;
        
    sum_est_stoi = sum_est_stoi / count;
    sum_est_pesq = sum_est_pesq / count;
    sum_est_snr = sum_est_snr / count;
    sum_est_sdr = sum_est_sdr / count;
    
    json_str = sprintf('{"mix_stoi":%.6f, "mix_pesq":%.6f, "mix_snr":%.6f, "mix_sdr": %.6f, "est_stoi":%.6f, "est_pesq":%.6f, "est_snr":%.6f, "est_sdr": %.6f}', sum_mix_stoi, sum_mix_pesq, sum_mix_snr, sum_mix_sdr, sum_est_stoi, sum_est_pesq, sum_est_snr, sum_est_sdr);
    % disp(json_str);
    fid = fopen(out_file_path,'w');
    fprintf(fid,'%s\n',json_str); 
    fclose(fid);
end

