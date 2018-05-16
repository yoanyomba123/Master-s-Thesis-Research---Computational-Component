function res = estimateNoise(octimg, Params)
% estimateNoise is a method aimed at estimating the amount of noise present
% within an OCT image
% Inputs:
%   OCT image
%   Parameters containing the estimated window size for the application of
%   the median filter
% Output:
%   estimated image noise
    octimg = octimg - mean(mean(octimg)); 
    mimg = medfilt2(octimg, Params.ONFLLIN_SEGMENT_NOISEESTIMATE_MEDIAN);
    octimg = mimg - octimg;

    octimg = abs(octimg);

    line = reshape(octimg, numel(octimg), 1);
    res = std(line);
end
