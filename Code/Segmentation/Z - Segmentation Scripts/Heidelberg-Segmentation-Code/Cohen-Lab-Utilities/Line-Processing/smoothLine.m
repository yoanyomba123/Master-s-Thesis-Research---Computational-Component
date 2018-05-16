function line = smoothLine(line, w_s, degree)
% Smoothes a line based on a moving polynomial fitting method
if nargin < 3 && nargin >= 1
    w_s = 50;
    degree = 10;


for i = 1: size(line, 1)
    line(i,:) = lineProcessing(size(line(i, :),2),line(i,:),w_s,degree);
    line(i, :) = medfilt1(line(i, :), degree);
end

end

