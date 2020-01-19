function y = convolution2d(x, w, b, model, atrous_rate, reorder)
if nargin<6
    reorder = 1;
end
if nargin<5
    atrous_rate = [1, 1];
end
    
if nargin<4
    model = 'full';
end

if reorder
    x = permute(x, 4:-1:1);
    w = permute(w, 4:-1:1);
end
y0 = conv2(x(:,:,1,1), atrous(w(:,:,1,1), atrous_rate), model);
y = zeros([size(y0,1), size(y0,2), size(w,4), size(x,4)]);

for i = 1:size(w,4)
    for j = 1:size(x,4)
        for c = 1:size(x,3)
            y(:,:,i,j) = y(:,:,i,j) + conv2(x(:,:,c,j), atrous(w(:,:,c,i), atrous_rate), model);
        end
        y(:,:,i,j) = y(:,:,i,j) + b(i);
    end
end

if reorder
    y = permute(y, 4:-1:1);
end

function y = atrous(x, rate)
y = zeros((size(x,1)-1)*rate(2)+1, (size(x,2)-1)*rate(1)+1);
for i=1:size(x,1)
    for j=1:size(x,2)
        y((i-1)*rate(2)+1, (j-1)*rate(1)+1) = x(i,j);
    end
end