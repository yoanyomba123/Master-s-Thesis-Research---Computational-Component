function WriteToFile(name,pathname, data, ROOT,index)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

startfolder = pathname;
x = strcat(startfolder,strcat('\',name));

if ~exist(x, 'dir'); 
    mkdir(startfolder,name);
    v = strcat(startfolder, strcat('\',strcat(name,'\')));
    disp(v)
    fileattrib(x,'+w')
    fileattrib(fullfile(v),'+w')

    

end
% Convert images to h5 and json format
for i=1:numel(data)    
    im = data{1,i};
    % make sure leverjsUtilities project is on your path!
    % e.g. path(path,'pathTo\git\utilities\src\MATLAB')
    fileattrib(x,'+h -w','','s');    
    imwrite(im,fullfile(x),'tif');
    imd=MicroscopeData.MakeMetadataFromImage(im);
    if (ROOT(end)=='/' || (ROOT(end)=='\'))
        [~,expName,~]=fileparts(ROOT(1:end-1));
    else
        [~,expName,~]=fileparts(ROOT(1:end));
    end
    imd.DatasetName=expName;
    if (size(imd.Dimensions,2)~=3)
        imd.Dimensions=[imd.Dimensions 1];
    end
    MicroscopeData.WriterH5(im,'imageData',imd,'path',x);
end

