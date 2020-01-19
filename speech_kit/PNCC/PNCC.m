%
% Programmed by Chanwoo Kim for the ICASSP 2010
%
% (chanwook@cs.cmu.edu)
%
% Important: The input should be mono and be sampled at "16 kHz".
%
% * In the source code, if you want to skip the power bais subtraction, then
% change bMedPowerBiasSub to 0 (line 27)
%
% * If you want to use logarithmic nonlinearity instead of the power
% nonlinearity, change bPowerLaw to 0 (lilne 28)
%
% PNCC_ICASSP2010(OutFile, InFile)
%
function [aadDCT_DD] = PNCC(ad_x)
	%fid = fopen(szInFileName, 'rb');
	%fseek(fid, 1024, 'bof');
	%ad_x  = fread(fid, 'int16');
	%fclose(fid);
    
    addpath('../');
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% Flags
    %
    bPreem           = 1;
    bMedPowerBiasSub = 1;
    bPowerLaw        = 1;
    bDisplay         = 0;
    iInitBufferSize  = 10;
    dDelta           = 0.01;
	iM               = 2;
    iN               = 4;
   
	dPowerCoeff  = 1 / 15;
	%dFrameLen    = 0.0256;  % 25.6 ms window length, which is the default setting in CMU Sphinx
	dFrameLen    = 0.020;  % 25.6 ms window length, which is the default setting in CMU Sphinx
	dSampRate    = 16000;
	dFramePeriod = 0.010;   % 10 ms frame period
	iPowerFactor = 1;

	iFL        = floor(dFrameLen    * dSampRate);
	iFP        = floor(dFramePeriod * dSampRate);
	iNumFrames = floor((length(ad_x) - iFL) / iFP) + 1;
    ad_x = [ad_x; zeros(iNumFrames*iFP+iFL-length(ad_x),1)];
    iSpeechLen = length(ad_x);
    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% Pre-emphasis using H(z) = 1 - 0.97 z ^ -1
	%
	if (bPreem == 1)
		ad_x = filter([1 -0.97], 1, ad_x);
    end
  
	iFFTSize  = 1024;
	iNumFilts = 40;
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% Obtaning the gammatone coefficient. 
	%
    % Based on M. Snelly's auditory toolbox. 
    % In actual C-implementation, we just use a table
    %
 	aad_H = ComputeFilterResponse(iNumFilts, iFFTSize);
	aad_H = abs(NormalizeFilterGain(aad_H));
	
	i_FI = 0;
    adSumPower = zeros(1, iNumFrames);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% Obtaining the short-time Power P(i, j)
	%
	for m = 0 : iFP : (iNumFrames-1) * iFP
		ad_x_st                = ad_x(m + 1 : m + iFL) .* hamming(iFL);
        adSpec                 = fft(ad_x_st, iFFTSize);
        ad_X                   = abs(adSpec(1: iFFTSize / 2));
        aadX(:, i_FI + 1)      = ad_X; 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Calculating the Power P(i, j)
        %
        for j = 1 : iNumFilts
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                % Squared integration
                %
                aad_P( j , i_FI + 1)  = sum((ad_X .* aad_H(:, j)) .^ 2);
        end
        adSumPower(i_FI + 1) = sum(aad_P( : , i_FI + 1));
        i_FI = i_FI + 1;
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% Peak Power Normalization Using 95 % percentile
	%
	adSorted  = sort(adSumPower);
	dMaxPower = adSorted(round(0.95 * length(adSumPower)));
	aad_P     = aad_P / dMaxPower * 1e15;
    
    if bMedPowerBiasSub == 1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Medium-duration power calculation
        % 
        for j = 1 : iNumFrames,
             for i = 1 : iNumFilts,
                aad_Q(i, j) =  mean(aad_P(i, max(1, j - iM) : min(iNumFrames, j + iM)));
             end
        end
        

        aad_w        = zeros(size(aad_Q));
        aad_w_Smooth = zeros(size(aad_Q));

        for i = 1 : iNumFilts,
            aad_tildeQ(i, :) = PowerBiasSub(aad_Q(i, :), dDelta);
            aad_w(i, :)      = max(aad_tildeQ(i, :), eps) ./ max(aad_Q(i, :), eps);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Weight smoothing aross channels
        % 
        for j = 1 : iNumFrames,
            for i = 1 : iNumFilts,
                aad_w_Smooth(i, j) = mean(aad_w(max(i - iN , 1) : min(i + iN , iNumFilts) , j));
            end   
        end

        aad_P = aad_w_Smooth .* aad_P; 

% 			aad_P(:,1 :  iM)             = [];
% 			[iNumFilts, iLen]            = size(aad_P);
% 			aad_P(:, iLen - iM : iLen)   = [];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Apply the nonlinearity
    %
    if bPowerLaw == 1
        aadSpec = aad_P .^ dPowerCoeff;
    else
        aadSpec = log(aad_P + eps);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % DCT
    %
    aadDCT                  = dct(aadSpec);
    aadDCT(32:iNumFilts, :) = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % CMN
    %
    for i = 1 : 31
           aadDCT(i, : ) = aadDCT(i, : ) - mean(aadDCT(i, : ));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Writing the feature in Sphinx format
    %
    
    %[iM, iN] = size(aadDCT);
    %iNumData = iM * iN;
    %fid = fopen(szOutFeatFileName, 'wb');
    %fwrite(fid, iNumData, 'int32');
    %iCount = fwrite(fid, aadDCT(:), 'float32');
	%fclose(fid);
   
    del = deltas(aadDCT);
    
    ddel = deltas(deltas(aadDCT,5),5);
    
    aadDCT_DD = [aadDCT;del;ddel];
%     aadDCT_DD = aadDCT;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Display
    %
    if bDisplay == 1
        figure
        aadSpec = idct(aadDCT, iNumFilts);
        imagesc(aadSpec); axis xy;
    end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Power Bias Subtraction Algorithm
%
% Bias level is obtained by maximizing the AM-GM ratio
% 
function [ad_tildeQ] = PowerBiasSub(ad_Q, dDelta)
  
      dNormPower = 1e15;
      ad_B  = [0 dNormPower ./ (10 .^((70 : -1 : 10) / 10) + 1)];
      
      d_tildeGTemp = 0;
      ad_tildeQSave   = ad_Q;
  
      for d_B = ad_B
          
          aiIndex       = find(ad_Q > d_B);
          if (length(aiIndex) == 0)
              break
          end
         
          dPosMean = mean(ad_Q(aiIndex) - d_B);
          aiIndex       = find(ad_Q > d_B + dDelta *  dPosMean);
          if (length(aiIndex) == 0)
              break
          end
          
          d_cf      = mean(ad_Q(aiIndex) - d_B) * dDelta;
          ad_tildeQ = max(ad_Q - d_B, d_cf);
          adData    = ad_tildeQ(aiIndex);
  
          d_tildeG = log(mean(adData)) - mean(log(adData));
          if (d_tildeG > d_tildeGTemp)
              ad_tildeQSave = ad_tildeQ;
              d_tildeGTemp  = d_tildeG;
          end
      end
  
      ad_tildeQ = ad_tildeQSave;
  end
