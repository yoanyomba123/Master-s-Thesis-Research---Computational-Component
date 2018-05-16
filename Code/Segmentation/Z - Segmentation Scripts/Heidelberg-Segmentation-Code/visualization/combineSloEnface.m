function combImg = combineSloEnface(slo, enfaceView, position, mode, opacity)
% COMBINESLOENFACE Combines the SLO image with an enface image. The
% enfaceView might be transparent.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2011
% Revised comments: November 2015

if nargin < 4
    mode = 'replace';
    opacity = [];
end

combImg = slo;
if size(slo,3) == 1
    combImg(:,:,2) = combImg;
    combImg(:,:,3) = combImg(:,:,1);
end

if size(enfaceView,3) == 1
    enfaceView(:,:,2) = enfaceView;
    enfaceView(:,:,3) = enfaceView(:,:,1);
end

if numel(opacity) ~= 1
    opacity(:,:,2) = opacity;
    opacity(:,:,3) = opacity(:,:,1);
end

if strcmp(mode, 'replace')
    combImg(position(1):position(2), position(3):position(4), :) = enfaceView;
elseif strcmp(mode, 'overlay')
    combImg(position(1):position(2), position(3):position(4), :) = ...
        combImg(position(1):position(2), position(3):position(4), :) .* (1 - opacity) + enfaceView .*  opacity;
end

end