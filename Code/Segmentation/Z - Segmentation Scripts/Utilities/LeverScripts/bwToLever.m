function bwToLever(image, db_path_name)
%BWTOLEVER Converts a 2D logical black and white image to a 3D Lever
%version
%   bwToLever(IMAGE, DB_PATH_NAME) converts a black and white image to its
%   lever 3D complement. It takes as input IMAGE which is a black and white
%   image. DB_PATH_NAME is the path name of the local lever database on the
%   file system.

bw = image;
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

conn = database(db_path_name, '','', 'org.sqlite.JDBC', 'jdbc:sqlite:');
Write.CreateCells_3D(conn,Layers);

end

