function onfl = SegmentOnflStack(BScans,infl,ipl,icl,opl,bv,Params)

flatscans = [];
for i = 1: size(BScans, 3)
    [onflAuto, flatONFL, flatINFL,flatIPL,flatICL,alignedBScanDSqrt ] = SegmentOnfl(BScans(:,:,i),infl(i,:),ipl(i,:),icl(i,:), opl(i,:),bv(i,:),Params);
    onfl(i, :) = onflAuto;

    
end

end

