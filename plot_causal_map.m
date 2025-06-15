%====================================================================
%  plot_causal_map  —  2-D causal diagram (P vs C)
%--------------------------------------------------------------------
% INPUT  : P      —  n×1 prominence vector
%          C      —  n×1 relation   vector
%          names  —  n×1 string labels for the scatter points
%          ax     —  (optional) target axes handle; creates new fig if omitted
% OUTPUT : h      —  scatter object handle
% STEPS  :
%   1. Create / clear axes.
%   2. Scatter plot, grid, axis lines.
%   3. Annotate each factor.
%====================================================================
function h = plot_causal_map(P,C,names,ax,titleStr)

    if nargin<4 || isempty(ax)
        figure; ax = gca;
    end
    axes(ax); cla(ax,'reset');

    h = scatter(P,C,'filled'); grid on
    xlabel('Prominence (P)'); ylabel('Relation (C)');
    if nargin>4 && ~isempty(titleStr); title(titleStr); end
    hold on; yline(0); xline(mean(P));
    if ~isempty(names)
        text(P+0.01*max(P),C,names,'FontSize',8);
    end
    hold off
end