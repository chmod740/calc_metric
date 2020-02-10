function neg_log_p = neglogsigmoid(log_odds)
    neg_log_p = -log_odds;
    e = exp(-log_odds);
    f=find(e<e+1);
    neg_log_p(f) = log(1+e(f));
end