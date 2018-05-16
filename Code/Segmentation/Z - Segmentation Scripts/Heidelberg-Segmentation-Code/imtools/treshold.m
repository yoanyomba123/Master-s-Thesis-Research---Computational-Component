function bscan = treshold(bscan, mode, factor)
% TRESHOLD A-Scan base tresholding.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2010
% Revised comments: November 2015

if strcmp(mode, 'ascanmax')
    for i = 1:size(bscan, 2)
        ascan = bscan(:,i);
        val = sort(ascan);
        firstTreshold = val(round(end * factor(1)));
        ascan(ascan > firstTreshold) = firstTreshold;
        ascan(ascan < firstTreshold * factor(2)) = 0;
        bscan(:,i) = ascan;
    end
end