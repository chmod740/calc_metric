function [CCF] = binauralfeature(lsignal,rsignal,numchan,fs)
    lg = gammatone(lsignal,numchan,[50,fs/2],fs);
    rg = gammatone(rsignal,numchan,[50,fs/2],fs);
    CCF = crosscorrelogram((lg),(rg),fs);
end    
function ccf = crosscorrelogram(lg,rg,fs)
    tdnumber = fs*0.001;
    offset   = fs*0.01;
    winlen   = fs*0.02;
    tdwlen   = winlen-tdnumber;
    lg = max(lg,0); rg = max(rg,0);
    [numchan,siglen] = size(lg);
    numfrm = floor((siglen-winlen)/offset);
    ccf = zeros(numchan,numfrm,tdnumber*2-1);
    for chn = 1:numchan
        for frm = 1:numfrm
            sll1 = lg(chn,(frm-1)*offset+1:(frm-1)*offset+tdwlen);
%             sll1 = sll1 - mean(sll1);
            slr2 = rg(chn,(frm-1)*offset+1:(frm-1)*offset+tdwlen);
%             slr2 = slr2 - mean(slr2);
            for ti = 1:tdnumber                
                slr1 = rg(chn,(frm-1)*offset+ti:(frm-1)*offset+ti+tdwlen-1);                
%                 slr1 = slr1 - mean(slr1);
                sll2 = lg(chn,(frm-1)*offset+ti:(frm-1)*offset+ti+tdwlen-1);
%                 sll2 = sll2 - mean(sll2);
                tileft(ti) = sll1*slr1'/sqrt(sll1*sll1'*(slr1*slr1')+1.0e-6);
                tiright(ti)= sll2*slr2'/sqrt(sll2*sll2'*(slr2*slr2')+1.0e-6);
            end
            ccf(chn,frm,:) = [tiright(end:-1:2) tileft(1:end)];
        end
    end
end
