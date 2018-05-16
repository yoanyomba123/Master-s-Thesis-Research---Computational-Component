function boundaries = corrBoundaryOrder(boundaries)
% CORRBOUNDARYORDER Helper function for the experimental OCT volume 
% layer position optimization. Orders two volume boundaries.

for i = 1:numel(boundaries) - 1
    boundaries{i}(boundaries{i} > boundaries{i + 1}) = ...
        boundaries{i + 1}(boundaries{i} > boundaries{i + 1});
    boundaries{i + 1}(boundaries{i + 1} < boundaries{i}) = ...
        boundaries{i}(boundaries{i + 1} < boundaries{i});
end