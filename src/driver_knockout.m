%====================================================================
%  driver_knockout  —  leverage test (crisp | fuzzy)
%--------------------------------------------------------------------
% INPUT  : A      — original n×n numeric matrix (0…4)
%          Pbase  — base prominence vector (crisp or fuzzy)
%          mode   — "crisp" | "fuzzy"
% OUTPUT : delta  — n×1 percentage drop in ΣP when row k is zeroed
%====================================================================
function delta = driver_knockout(A,Pbase,mode)

n     = size(A,1);      delta = zeros(n,1);
for k = 1:n
    Ak = A;  Ak(k,:) = 0;                         % remove driver k
    switch mode
        case "crisp"
            lam = max(sum(Ak,2));
            if lam==0, delta(k)=0; continue; end
            Tk  = (Ak/lam) / (eye(n)-Ak/lam);
            Pk  = sum(Tk,2) + sum(Tk,1)';
        case "fuzzy"
            Pk  = dematel_fuzzy(Ak).P;            % call fuzzy engine
        otherwise
            error("Mode must be 'crisp' or 'fuzzy'");
    end
    delta(k) = (sum(Pbase) - sum(Pk)) / sum(Pbase);
end
end
