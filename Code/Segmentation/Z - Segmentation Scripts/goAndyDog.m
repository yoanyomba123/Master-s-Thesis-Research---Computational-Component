% %% Write image raw
load  imagedb.mat 

% adding specific folders to current path
addpath(genpath('.'));
addpath(genpath('D:\Yoan\Git\leverUtilities\src\MATLAB'));
addpath(genpath('D:\Yoan\Git\leverjs'));
addpath('D:\Yoan\Git\leverjs\matlab\');

% adding specific folders to current path
addpath(genpath('.'));
addpath(genpath('D:\Yoan\Git\leverUtilities\src\MATLAB'));
addpath(genpath('D:\Yoan\Git\leverjs'));
addpath('D:\Yoan\Git\leverjs\matlab\');
Normal = BScans_stack{1, 3};
% % write to h5 lever format in specified folder
% curr_path = 'D:\Yoan\DATA\NORMAL\';
% vol_name = 'NORMALRAW1';
% volumeToH5(Normal, char(vol_name), char(curr_path));
% Import.leverImport(curr_path, char(curr_path), char(vol_name), '');
% 
% 
% 
strDB ='D:\Yoan\DATA\NORMAL\NORMALRAW1.LEVER'
AddSQLiteToPath();
conn = database(strDB, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
CONSTANTS=Read.getConstants(conn);
% % sigma = 7;
% type = ""
% volume = dog3D(volume, sigma, type);
Normal(1:100, :,:) = min(Normal(:)); 
Normal(300:end, :,:) = min(Normal(:));

tic
sigma=5;
% First Gaussian Operation
imd1 = imgaussfilt3(Normal,sigma/sqrt(2));
imd2 = imgaussfilt3(Normal,sigma*sqrt(2));
imdog = imd1 - imd2;




% find image borders

lm=multithresh(imdog,3);
q=imquantize(imdog,lm);
imp=max(imdog,[],3);
q(1:100, :,:) = min(q(:)); 
q(300:end, :,:) = min(q(:));
imp=max(q,[],3);figure;imagesc(imp);

for i = 400:size(imp,2)
   imp(i, :) = 0;
end

figure;imagesc(imp); colorbar
bw=logical(q>=3);



[faces,verts]=isosurface(bw,eps);
norms = isonormals(bw,verts);
edges=Segment.MakeEdges(faces);

% make edges and faces zero indexed
edges=edges-1;
faces=faces-1;

% subtract extract for padding
maxRad = verts-repmat(mean(verts,1),size(verts,1),1);
maxRad=sum(abs(maxRad),2);
maxRad=max(maxRad);
newCell=[];
newCell.time=1;
newCell.centroid=[mean(verts,1)]-1;
newCell.edges=edges;
newCell.faces=faces;
newCell.verts=verts;
newCell.normals=norms;
xyzPts=[];

idxPixels=find(bw);
% note that xyzPts are on the correct range, as idxPixels is unpadded...
[xyzPts(:,2),xyzPts(:,1),xyzPts(:,3)]=ind2sub(size(bw),idxPixels);

newCell.pts=uint16(xyzPts);
newCell.maxRadius=maxRad;
newCell.channel=1;

Write.CreateCells_3D(conn,newCell)
toc