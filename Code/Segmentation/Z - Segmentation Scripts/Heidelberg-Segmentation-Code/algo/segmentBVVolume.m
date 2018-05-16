function bvAuto = segmentBVVolume(volume, params, onh, rpe)
% SEGMENTBVVOLUME Segment the blood vessels from a volume scan.
%
% This is an experimental adaption of the circular scan algorithm to volume
% scans. Preliminar results were published at the ARVO conference 2011:
% Markus A. Mayer, Joachim Hornegger, Christian Y. Mardin, Ralf P. Tornow;
% Retinal Layer Segmentation on OCT-Volume Scans of Normal and 
% Glaucomatous Eyes. Invest. Ophthalmol. Vis. Sci. 2011;52(14):3669
%
% Due to the lack of data and time the approach was not pushed further.
% Now (2015) we would suggest using other volume segmentation approaches.
%
% Writen by Markus Mayer, Pattern Recognition Lab, University of
% Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% First final Version: November 2010
% Revised comments: November 2015



volume(volume > 1) = 0;
volume = sqrt(volume);

bvAuto = zeros(size(volume, 3), size(volume, 2), 'uint8');

for i = 1:size(volume, 3)
    bvAuto(i,:) = segmentBVLin(volume(:,:,i), params, onh(i,:), rpe(i,:));
    
    disp(['Blood Vessels of BScan ' num2str(i) ' segmented automatically in 2D.']);
end

end