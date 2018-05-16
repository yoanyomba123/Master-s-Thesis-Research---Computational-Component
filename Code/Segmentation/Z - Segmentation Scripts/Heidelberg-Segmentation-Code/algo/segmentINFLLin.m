function [inflAuto, inflChoice] = segmentINFLLin(bscan, PARAMS, rpe, medline)
% SEGMENTINFLLIN Segments the INFL from a linear B-Scan, e.g. from slice of
% a volume.
%
% For detailed comments refer to segmentINFLCirc(..).
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

% 1) Normalize intensity values and align the image to the RPE
bscan = sqrt(sqrt(bscan));
[alignedBScan, flatRPE, transformLine] = alignAScans(bscan, PARAMS, rpe);
medline = round(medline - transformLine);
medline(medline < 0) = 0;
inflChoice = zeros(3, size(bscan, 2));

% 2) Some error handling/constraints are performed here. The medline can 
% not lay below the RPE. The medline is smoothed some more - actually, the
% linesweeter parameters should only be set to do hole interpolation.
medline(medline > flatRPE) = flatRPE(medline > flatRPE);
diffRpeMed = flatRPE - medline;
medline(diffRpeMed < 5) = 0;
medline = linesweeter(medline, PARAMS.INFL_SEGMENT_LINESWEETER_MEDLINE);
medline = round(medline);

% Instead of separatly normalizing the IS and OS, simple A-Scan based 
% intensity thresholding is applied.
snBScan = treshold(alignedBScan, 'ascanmax', [0.97 0.6]);

% 3) Find the INFL in the upper region of the scan 
linereg = [zeros(1, size(bscan,2), 'double') + 2; medline - PARAMS.INFL_MEDLINE_MINDISTABOVE];

inflAuto = findRetinaExtrema(snBScan, PARAMS, 1, 'max', ...
                            [zeros(1, size(bscan,2), 'double') + 2; medline - PARAMS.INFL_MEDLINE_MINDISTABOVE]);
                        
inflAuto = inflAuto(1,:);

% 4) Transformation of segmentation results from the aligned-RPE image back
% to the original one
inflAuto = inflAuto + transformLine;
inflAuto(inflAuto < 1) = 1;

% 5) Some additional smoothing
inflAuto =  linesweeter(inflAuto, PARAMS.INFL_SEGMENT_LINESWEETER_FINAL);
inflChoice(1,:) = inflAuto;

% X) Some additional data is generated for the discrete optimization
% approach. This was also not pushed further. You may comment this out if
% you'll only are interested in volume segmentation.
inflSimple = findRetinaExtrema(snBScan, PARAMS, 2, 'max', [zeros(1, size(bscan,2), 'double') + 2; flatRPE]);
inflSimple =  linesweeter(inflSimple, PARAMS.INFL_SEGMENT_LINESWEETER_FINAL); 
inflSimple(inflSimple < 1) = 1;
inflChoice(3,:) = inflSimple(2,:) + transformLine;
inflSimple = inflSimple(1,:);
inflChoice(2,:) = inflSimple + transformLine;

end