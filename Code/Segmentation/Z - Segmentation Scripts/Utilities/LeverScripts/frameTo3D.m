function newCell=frameTo3D(idxPixels, imSize, channel, time, ...
    conn, params)

bwn=zeros(imSize);
bwn(idxPixels)=1;
PAD=5;
% padd with extra zeros around the outside so our mesh covers boundaries
bpad = zeros(size(bwn)+10);
bpad(PAD+1:end-PAD,PAD+1:end-PAD,PAD+1:end-PAD)=bwn;
bwn = bpad;
% scale=[1,1,1];
scale=max(imSize)./imSize/8;
scale=max(min(scale,0.5),.01);
%
resize=round(scale.*size(bwn));
bwResize=imresize3(bwn,resize);
[faces,verts]=isosurface(bwResize,graythresh(bwResize));
if size(verts,1)<10
    resize=round(2*scale.*size(bwn));
    bwResize=imresize3(bwn,resize);
    [faces,verts]=isosurface(bwResize,graythresh(bwResize));
end

norms = isonormals(bwResize,verts);
% rescale verts back to 
unscale=(size(bwn)./size(bwResize));
% put unscale on x,y instead of r,c
unscale=[unscale(2),unscale(1),unscale(3)];

verts=(verts).*unscale-0.5*unscale;
edges=Segment.MakeEdges(faces);
 
% make edges and faces zero indexed
edges=edges-1;
faces=faces-1;

% subtract extract for padding
verts=verts-PAD;
maxRad = verts-repmat(mean(verts,1),size(verts,1),1);
maxRad=sum(abs(maxRad),2);
maxRad=max(maxRad);
newCell=[];
newCell.time=time;
newCell.centroid=[mean(verts,1)]-1;
newCell.edges=edges;
newCell.faces=faces;
newCell.verts=verts;
newCell.normals=norms;
xyzPts=[];
% note that xyzPts are on the correct range, as idxPixels is unpadded...
[xyzPts(:,2),xyzPts(:,1),xyzPts(:,3)]=ind2sub(imSize,idxPixels);

newCell.pts=uint16(xyzPts);
newCell.maxRadius=maxRad;
newCell.channel=channel;