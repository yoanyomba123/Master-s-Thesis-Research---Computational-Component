function reflection = getReflection(bScans, border1, border2)
% GETREFLECTION Sums intensitie values alon A-Scans in a certain range.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2011
% Revised comments: November 2015

border1 = round(border1);
border2 = round(border2);

if numel(border2) == 1
    if border2 > 0
        border2 = border1 + border2;
    else
        temp = border2;
        border2 = border1;
        border1 = border1 + temp;
    end
end

border1(border1 < 1) = 1;
border1(border1 > size(bScans, 1)) = size(bScans, 1);

border2(border2 < 1) = 1;
border2(border2 > size(bScans, 1)) = size(bScans, 1);

reflection = zeros(size(border1));
for i = 1:size(bScans, 2)
    vec = bScans(border1(i):border2(i), i);
    reflection(i) = sum(vec);
end

end