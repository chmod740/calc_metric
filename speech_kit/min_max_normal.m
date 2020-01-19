function y = mmnormal(s)
mm = minmax(s(:)');
a = mm(1);
b = mm(2);
y = (s-a)./(b-a);