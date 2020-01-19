function [ hev ] = GetEnvelope( hc )

sampFreq = 16000;
passBand = 2 * pi * 1000 / sampFreq;
stopBand = 2 * pi * 1200 / sampFreq;


A = -20 * log10(0.01);
if( A > 50 )
    alpha = 0.1102 * (A - 8.7);
else if ( A > 21 && A <= 50 )
        alpha = 0.5842 * (A-21)^0.4 + 0.07886 * (A - 21);
    else
        alpha = 0;
    end
end

N = (A - 7.95) / (2.285 * abs(stopBand - passBand));

L = round(N) + 1;

if( mod(L, 2) ~= 0 )
    L = L + 1;
end

kaiserWindow = kaiser(L + 1, alpha);

cutFreq = (passBand + stopBand) / (2*pi);

n = 0:1:L;

h = cutFreq * sinc(cutFreq * (n - L/2));

h = h .* kaiserWindow';

hev = zeros(128, size(hc, 2));
for  i = 1 : 128
    for j = 1 : size(hc, 2)
        for z = 1 : size(h, 2)
            shift = j + L/2 + 1 - z;
            if( shift > 0 && shift <= size(hc, 2) )
                hev(i, j) = hev(i, j) + hc(i, shift) * h(z);
            end
        end
    end
end


end