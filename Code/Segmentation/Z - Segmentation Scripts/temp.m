addpath(genpath('.'));
addpath(genpath('D:\Yoan\Git\leverUtilities'));
addpath(genpath(('D:\Yoan\Git\leverjs')));

volume = BScans_stack{1,1};

strDB='D:\Yoan\data\3draw.LEVER';
AddSQLiteToPath();
conn = database(strDB, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');


path_name = 'D:\Yoan\data';

% export raw to h5
imd=MicroscopeData.MakeMetadataFromImage(volume);
if (size(imd.Dimensions,2)~=3)
    imd.Dimensions=[imd.Dimensions 1];
end

% wrtie to lever
imd.DatasetName='3draw';
MicroscopeData.WriterH5(volume,'imageData',imd,'path',path_name);

Import.leverImport('',path_name);