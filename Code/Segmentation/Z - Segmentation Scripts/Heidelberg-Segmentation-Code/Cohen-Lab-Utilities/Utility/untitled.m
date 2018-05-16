function F = fuzzysysfcn(inmf, outmf, vrange, op)
% Creates a fuzzy system function F corresponding to a set of rules and
% output membership function.

% INMF is an M-by-N matrix of input membership function handles
% M is the number of rules and N is the number of fuzzy system inputs

% OUTMF is a cell array containing output membership functions.
% numel(outmf) can be either m or m+1 and if it is M+1 then the extra
% output membership function is used for an automatically computed else
% rule. 

% VRANGE is a two element vector specifying the valid range of input
% values for the output membership function. 

% OP is the function handle
% specifying how to combine the antecedents for each rule. OP can be either
% @min or @max. if OP is omitted @min is used

% The output F is a function handle that computes the fuzzy system's output
% given a set of inputs using the syntax 
%
%   out = F(Z1, Z2, Z3, Z4)

if(nargin < 4)
    op = @min
end

% The lambda functions are independent of the inputs Z1, Z2, ...., and can
% thus be computed pre maturely
L = lambda

end

