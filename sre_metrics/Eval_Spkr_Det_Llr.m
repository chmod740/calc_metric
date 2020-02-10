load true_speaker_scores %target
load impostor_scores  % nontarget

%COMPLETAR: Graficar la curva DET 
[Pmiss,Pfa] = Compute_DET(true_speaker_scores,impostor_scores);
Plot_DET(Pmiss,Pfa,'r');

%COMPLETAR: calcular Cllr y m¨ªnimo Cllr
CLLR = cllr(true_speaker_scores,impostor_scores)
minCLLR = min_cllr(true_speaker_scores,impostor_scores)

%EER: Error en el punto en que Pfa == Pmiss
[val, ind] = min(abs(Pmiss-Pfa));
EER = (Pmiss(ind)+Pfa(ind)) / 2 % El EER es de ~25%