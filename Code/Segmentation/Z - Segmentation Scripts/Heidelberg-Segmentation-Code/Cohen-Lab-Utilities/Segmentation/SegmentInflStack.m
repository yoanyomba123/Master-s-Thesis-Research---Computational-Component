function [inflAuto] = SegmentInflStack(BScans,params, rpe, medline)


for i = 1: size(BScans, 3)
    [inflLin, inflLinChoice]= segmentINFLLin(BScans(:,:,i), params, rpe(i,:), medline(i,:));
    inflAuto(i,:) = inflLin;


    
end

end

