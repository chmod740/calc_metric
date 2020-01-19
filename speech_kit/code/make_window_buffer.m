function ret = make_window_buffer(X, side_size)

% alternative to makeWindowFeat2_fix. Potentially faster

if side_size ~=0 
    [~, d] = size(X);
    X = [repmat(X(1,:), side_size,1); X; repmat(X(end,:), side_size, 1)]';
    winsize_in_frame = 2*side_size + 1;
    ret = buffer(X(:), d*winsize_in_frame, d*winsize_in_frame-d, 'nodelay')';
else
    ret = X;
end



% assert(size(ret,1) == nFrame);

% -------------------------------------------------
% X = [X; repmat(X(end,:), side_size, 1)];
% winsize_in_frame = 2*side_size + 1;
% [nFrame, d] = size(X);
% 
% vX = X'; vX = vX(:);
% % w = buffer(vX, d*winsize_in_frame, d*winsize_in_frame-d)';
% 
% %trim and padding
% w = w(side_size+1:end,:);
% ret = w;



% -------------------------------------------------
% % X = [X; repmat(X(end,:), side_size-1,1)];
% 
% side_size = side_size + 1;
% 
% [nFrame, d] = size(X);
% vX = X'; vX = vX(:);
% 
% % right side
% right = buffer(vX, d*side_size, d*side_size-d, 'nodelay')';
% z = zeros(nFrame - size(right,1), size(right,2));
% right = [right; z];
% 
% % left side
% left = buffer(vX, d*side_size, d*side_size-d)';
% left = left(1:nFrame,:);
% 
% left = left(:,1:end-d);
% ret = [left right];