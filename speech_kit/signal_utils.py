import numpy
def expand2frame(x,n):
    r,c = x.shape
    y = numpy.zeros((r,c*2*n+c));
    t = 0;
    for i in range(-n,n+1):
        y[:,t*c:t*c+c] = numpy.roll(x,i,0);
        t = t + 1;
    return y