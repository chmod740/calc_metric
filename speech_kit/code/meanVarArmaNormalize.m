function [mva_data,mu,std] = meanVarArmaNormalize(data,order)
% mean/var norm + ARMA filtering

[mv_data,mu,std] = meanVarNormalize(data);

if order == 0
    mva_data = mv_data;
else
    mva_data = doARMA(mv_data,order);
end

end
