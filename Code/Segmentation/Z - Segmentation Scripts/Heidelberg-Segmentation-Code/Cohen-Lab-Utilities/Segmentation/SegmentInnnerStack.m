function [ipl,opl, icl] = SegmentInnnerStack(BScans,rpe, infl, med,bv, Params)
% segments the inner layers of the ISG layer 
% input
%   3D volumetric BScans
%   rpe layer
%   infl layer
%   middle layer
%   blood vessel layer
% output
%   ipl layer
%   opl layer
%   icl layer
for i = 1: size(BScans, 3)
    [ipl_res, opl_res, icl_res] = SegmentInner(BScans(:,:,i),rpe(i,:),infl(i,:), med(i,:),bv(i,:),Params);
    ipl(i, :) = ipl_res;
    opl(i, :) = opl_res;
    icl(i, :) = icl_res;
end
end

