function oct = drawMarkerOct(octOrig, pos, color, thickness, opacity)
% DRAWMARKEROCT Draws a marker on an OCT BSscan image  
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2011
% Revised comments: November 2015

adder = thickness;

octR = octOrig(:,:,1);
octG = octOrig(:,:,2);
octB = octOrig(:,:,3);

octR = [zeros(size(octR,1), adder, 'single')  octR  zeros(size(octR,1), adder, 'single')];
octG = [zeros(size(octG,1), adder, 'single')  octG  zeros(size(octG,1), adder, 'single')];
octB = [zeros(size(octB,1), adder, 'single')  octB  zeros(size(octB,1), adder, 'single')];

pos = pos + adder;

octR(:,pos(1)-thickness:pos(1)+thickness) = opacity * color(1) + ...
                 (1 - opacity) * octR(:,pos(1)-thickness:pos(1)+thickness);
octG(:,pos(1)-thickness:pos(1)+thickness) = opacity * color(2) + ...
                 (1 - opacity) * octG(:,pos(1)-thickness:pos(1)+thickness);
octB(:,pos(1)-thickness:pos(1)+thickness) = opacity * color(3) + ...
                 (1 - opacity) * octB(:,pos(1)-thickness:pos(1)+thickness);

oct(:,:,1) = octR;
oct(:,:,2) = octG;
oct(:,:,3) = octB;

oct = oct(:, adder+1:end-adder, :);