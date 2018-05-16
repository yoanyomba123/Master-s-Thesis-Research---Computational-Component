function [subHeader, subBScanHeader, subSlo, subBScans] = createSubvolume(DataDescriptors, Data, range, align, blacken)
% CREATESUBVOLUME Create a subvolume in z-direction.
% 
% [SUBHEADER, SUBBSCANHEADER, SUBSLO, SUBBSCANS] 
%    = createSubvolume(DATADESCRIPTORS, DATA, RANGE, ALIGN, BLACKEN)
%
% DATADESCRIPTORS: See octsegMain.
% DATA: The volume data.
% RANGE: 2 layers to cut out the subvolume.
% ALIGN: Set this if the subvolume should be aligned to the lower boundary.
% BLACKEN: Set this if remaining volume outside the subvolume should be
% blackened.
% SUBHEADER, SUBBSCANHEADER, SUBSLO, SUBBSCANS: Descriptors of the
% subvolume that can be used to store the subvolume in .vol format.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: Some time in 2010
% Revised comments: November 2015

    subHeader = DataDescriptors.Header;
    subBScanHeader = DataDescriptors.BScanHeader;
    subSlo = Data.slo;

    range = round(range); 
    range(range < 1) = 1;
    range(range > size(Data.bScans, 1)) = size(Data.bScans, 1);   
    
if numel(range) == 2  
    subBScans = Data.bScans(range(1):range(2),:,:);
    
    subHeader.SizeZ = range(2) - range(1) + 1;
else
    dist = range(:,:,2) - range(:,:,1);
    meanDist = mean(mean(dist));
    
    if meanDist <= 0
        temp = range(:,:,1);
        range(:,:,1) = range(:,:,2);
        range(:,:,2) = temp(:,:,1);
        dist = -dist;
        if align == 1
            align = 2;
        elseif algin == 2
            align = 1;
        end
    end
    
    maxDist = max(max(dist));
    maxDist = maxDist + 1;
    
    if blacken
        rangeTemp = range;
        rangeTemp(rangeTemp < 2) = 2;
        rangeTemp(rangeTemp > size(Data.bScans, 1) - 1) = size(Data.bScans, 1) - 1;
            
        for i = 1:size(Data.bScans, 2)
            for j = 1:size(Data.bScans, 3)
                Data.bScans(1:rangeTemp(j,i,1),i,j) = 0;
                Data.bScans(rangeTemp(j,i,2):end,i,j) = 0;
            end
        end
    end
    
    if align == 0
        rangeTemp = [min(min(range(:,:,1))) max(max(range(:,:,2)))];
        subBScans = Data.bScans(rangeTemp(1):rangeTemp(2),:,:);
        subHeader.SizeZ = range(2) - range(1) + 1;
    elseif align == 1
        subBScans = zeros(maxDist, size(Data.bScans, 2), size(Data.bScans, 3), 'single');
        for i = 1:size(Data.bScans, 2)
            for j = 1:size(Data.bScans, 3)
                actDist = dist(j,i) + 1;               
                subBScans(1:actDist,i,j) = Data.bScans(range(j,i,1):range(j,i,2),i,j);
            end
        end
        subHeader.SizeZ = maxDist;
    else
        subBScans = zeros(maxDist, size(Data.bScans, 2), size(Data.bScans, 3), 'single');
        for i = 1:size(Data.bScans, 2)
            for j = 1:size(Data.bScans, 3)
                actDist = dist(j,i);               
                subBScans(end-actDist:end,i,j) = Data.bScans(range(j,i,1):range(j,i,2),i,j);
            end
        end
        subHeader.SizeZ = maxDist;
    end
end

end
