function outputline = lineProcessing(imagecollumnsize, line,windowsize,polynomialdegree)
% applies a polynomial fitting line to a line by sliding a window of
% pre-specified size along the original line and computing the fitting line
% Input
%   line vector -  a line vector comprise of 1 row and n cols
%   window size - an integer value
%   polynomialdegree - an integer value (use 4 or 5)
%   imagesize - the number of cols in an image


if(windowsize >= imagecollumnsize)
   windowsize = 300; 
end
window_size = 500;
polydegree = 8;

for item = 1:length(line)
    upperbound = item + window_size;
    lowerbound = item;
    if( item + window_size <= length(line))
       y_points = line(lowerbound:upperbound);
       x_points = 1:length(y_points);
       % fit polynomial to the line
       [p, S, mu] = polyfit(x_points,y_points, polydegree);
       % evaluate the fitted polynomial
       [ynew, ~] = polyval(p, x_points, S, mu);
       line_output(lowerbound:upperbound) = ynew;
    end
end

line = fliplr(line_output);
for item = 1:length(line)
    upperbound = item + window_size;
    lowerbound = item;
    if( item + window_size <= length(line))
       y_points = line(lowerbound:upperbound);
       x_points = 1:length(y_points);
       % fit polynomial to the line
       [p, S, mu] = polyfit(x_points,y_points, polydegree);
       % evaluate the fitted polynomial
       [ynew, ~] = polyval(p, x_points, S, mu);
       line_output(lowerbound:upperbound) = ynew;
    end
end
line_output = fliplr(line_output);
% for item = 1:length(line_output)
%     upperbound = length(line_output) - window_size - item;
%     lowerbound = length(line)-item;
%     if( length(line_output) - window_size - item <= length(line_output))
%        y_points = line(lowerbound:upperbound);
%        x_points = 1:length(y_points);
%        % fit polynomial to the line
%        [p, S, mu] = polyfit(x_points,y_points, polydegree);
%        % evaluate the fitted polynomial
%        [ynew, ~] = polyval(p, x_points, S, mu);
%        line_outputs(lowerbound:upperbound) = ynew;
%     end
% end


outputline = line_output;
end

