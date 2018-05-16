idxPixels=find(bw);
imSize=size(bw);
[faces,verts]=isosurface(bw,eps);
norms = isonormals(bw,verts);
edges=Segment.MakeEdges(faces);
 
% make edges and faces zero indexed
edges=edges-1;
faces=faces-1;

% subtract extract for padding
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
[xyzPts(:,2),xyzPts(:,1),xyzPts(:,3)]=ind2sub(imSize,idxPixels);

newCell.pts=uint16(xyzPts);
newCell.maxRadius=maxRad;
newCell.channel=1;

strDB='d:\andy\3draw.LEVER';
conn = database(strDB, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
Write.CreateCells_3D(conn,newCell)

