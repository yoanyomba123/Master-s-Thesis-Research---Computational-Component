function Cells=FrameSegment_OCT(conn);

%

strDB='D:\Yoan\DukeOCT\AMD\AMD1.LEVER';

conn = database(strDB, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');

CONSTANTS=Read.getConstants(conn);

im = MicroscopeData.Reader('imageData',CONSTANTS.imageData, 'chanList',1, ...
    'timeRange',[1 1],'outType','single','prompt',false);
bw = im * 0;

%%
% bw = onflvolume;
pts1 = round(iclines{1,2});
pts2 = round(iplines{1,2});
pts3 = round(inflines{1,2});
pts4 = round(oplines{1,2});
pts5 = round(rpelines{1,2});
pts6 = round(onflines{1,2});

for i = 1:size(pts, 2)
    for ii = 1:size(pts, 1)
        bw(pts1(ii, i),i,ii) = 1;
        bw(pts2(ii, i),i,ii) = 2;
        bw(pts3(ii, i),i,ii) = 3;
        bw(pts4(ii, i),i,ii) = 4;
        bw(pts5(ii, i),i,ii) = 5;
        bw(pts6(ii, i),i,ii) = 6;
    end
% 2d view
end

imagesc(any(bw,3))

%     imMIP=max(im,[],3);

% figure;imagesc(imMIP);colormap(gray);hold on

% lm=multithresh(imMIP,5);

% q=imquantize(imMIP,lm);

% figure;imagesc(q)

% idx=find( (q>1) & (q<6));

% bw=0*q;

% bw(idx)=1;

% [L,num]=bwlabel(bw);

% figure;imagesc(L)

%

lm=multithresh(im,5);

q=imquantize(im,lm);

bw=logical(bw);



CC = bwconncomp(bw);

[L num]=bwlabeln(bw);


 

Cells=[];

for n=1:num

    idxPixels=find(L==n);

 

    bwn=zeros(size(bw));

    bwn(idxPixels)=1;

    [faces,verts]=isosurface(bwn,graythresh(bwn));

   

    norms = isonormals(bwn,verts);

   

    edges=Segment.MakeEdges(faces);

   

    % make edges and faces zero indexed

    edges=edges-1;

    faces=faces-1;

   

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

    % note that xyzPts are on the correct range, as idxPixels is unpadded...

    [xyzPts(:,2),xyzPts(:,1),xyzPts(:,3)]=ind2sub(size(bw),idxPixels);

   

    newCell.pts=uint16(xyzPts);

    newCell.maxRadius=maxRad;

    newCell.channel=1;


    Cells=[Cells;newCell];

end


Write.CreateCells_3D(conn,Cells);


 

 

bwMIP=max(bw,[],3);

figure;imagesc(bwMIP)

 

