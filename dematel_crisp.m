%====================================================================
%  dematel_crisp  —  Falatoonitoosi, E., Leman, Z., Sorooshian, S., & Salimi, M. (2013) DEMATEL
%--------------------------------------------------------------------
% INPUT  : A  —  n×n direct-influence matrix (numeric 0 to 4)
% OUTPUT : out struct  (T, P, C, role)
% STEPS  :
%   1. Normalise A by max row-sum to D.
%   2. Compute total-relation matrix T = D(I-D)⁻¹.
%   3. Prominence P = rowSum + colSum
%      Relation   C = rowSum − colSum.
%   4. Tag factors as Cause (C > 0) | Effect (C < 0).
%====================================================================
function out = dematel_crisp(A)
    n        = size(A,1);
    lambda   = max(sum(A,2));          % 1 - normalisation coefficient
    D        = A / lambda;             
    I        = eye(n);

    T        = D / (I - D);            % 2 - total-relation matrix
    P        = sum(T,2) + sum(T,1)';   % 3 - prominence
    C        = sum(T,2) - sum(T,1)';   %     relation

    role = repmat("Effect",n,1);       % 4 - grouping
    role(C>0) = "Cause";

    out = struct("T",T,"P",P,"C",C,"role",role);
end
