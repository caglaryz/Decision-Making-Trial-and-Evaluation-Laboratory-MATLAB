%====================================================================
%  load_direct_matrix  —  Read linguistic influence matrix (+ names)
%--------------------------------------------------------------------
% INPUT  : matFile  —  *.csv / *.xlsx with row-col codes and NO/VL/L/H/VH
%          nameFile —  (opt.) names CSV, cols: Code,Description
% OUTPUT : A       —  n×n numeric (0…4)
%          codes   —  n×1 string  (F1…Fn)
%          desc    —  n×1 string  (readable names or codes if absent)
% STEPS  :
%   1. Read matrix, split codes + raw linguistic terms.
%   2. Convert linguistics to numeric via fixed map.
%   3. Attach descriptions when nameFile is supplied.
%====================================================================
function [A,codes,desc] = load_direct_matrix(matFile,nameFile)

% 1 - read
T     = readtable(matFile,'TextType','string');
codes = string(T{:,1});
raw   = T{:,2:end};

% 2. linguistic to numeric
labels = ["NO","VL","L","H","VH"];   scores = 0:4;
A = zeros(size(raw));
for k = 1:numel(raw)
    A(k) = scores(labels == upper(strtrim(raw(k))));
end

% 3. factor names (if available) 
if nargin < 2
    desc = codes;                       % ignore
else
    N        = readtable(nameFile,'TextType','string');
    [~,idx]  = ismember(codes,N.Code);
    desc     = N.Description(idx);
end
end
