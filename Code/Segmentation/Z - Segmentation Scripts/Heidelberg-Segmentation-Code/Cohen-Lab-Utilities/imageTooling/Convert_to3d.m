function Volume = Convert_to3d(cell_array)
% Convert_to3d converts the contents of a cell array to a 3D volumetric
% image
% Inputs:
%   cell array
% Outputs:
%   3D volumetric image

for i = 1: length(cell_array)
   Volume(:,:,i) = gather(cell_array{i}); 
end
end

