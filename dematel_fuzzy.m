%====================================================================
%  dematel_fuzzy — Lin & Wu (2008) Fuzzy DEMATEL
%--------------------------------------------------------------------
% INPUT  : idxMat — n×n matrix (codes 0…4 for NO,VL,L,H,VH)
% OUTPUT : out struct
%          • T_low/T_mid/T_up — total-relation TFN slices
%          • T               — CFCS-defuzzified total-relation matrix
%          • P , C           — Prominence / Relation
%          • role            — "Cause" | "Effect"
% STEPS  :
%   1. Map linguistic codes to TFNs.
%   2. Normalise upper slice by its max row-sum.
%   3. Compute total-relation slices: T = D(I−D)⁻¹.
%   4. Defuzzify T via CFCS (global min/max).
%   5. Calculate P (=D+R) and C (=D−R); tag causes/effects.
%====================================================================
function out = dematel_fuzzy(idxMat)
    % 1 - TFN map
    map = [0 0 0.25; 0 0.25 0.5; 0.25 0.5 0.75; 0.5 0.75 1; 0.75 1 1];
    n   = size(idxMat,1);

    A_low = reshape(map(idxMat+1,1),n,n);
    A_mid = reshape(map(idxMat+1,2),n,n);
    A_up  = reshape(map(idxMat+1,3),n,n);

    % 2 - Normalisation
    lambda = max(sum(A_up,2));    % upper slice row-sum
    D_low  = A_low/lambda;  D_mid = A_mid/lambda;  D_up = A_up/lambda;

    % 3 - Total-relation slices
    I = eye(n);
    T_low = D_low/(I-D_low);
    T_mid = D_mid/(I-D_mid);
    T_up  = D_up /(I-D_up);

    % 4 - CFCS defuzz
    Lg = min(T_low(:)); Rg = max(T_up(:));  Dg = Rg - Lg + eps;
    T  = Lg + ((T_mid-Lg).*(Dg + T_up - T_mid) + ...
               (T_up-Lg ).*(Dg + T_mid - Lg )) ./ (2*Dg);

    % 5 - Prominence & Relation
    P = sum(T,2) + sum(T,1)';
    C = sum(T,2) - sum(T,1)';

    role      = repmat("Effect",n,1);
    role(C>0) = "Cause";

    out = struct("T_low",T_low,"T_mid",T_mid,"T_up",T_up,...
                 "T",T,"P",P,"C",C,"role",role);
end
