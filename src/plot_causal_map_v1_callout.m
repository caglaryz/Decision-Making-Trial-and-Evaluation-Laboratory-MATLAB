function h = plot_causal_map_v1_callout(P, C, names, ax, titleStr)
% PLOT_CAUSAL_MAP_V1_CALLOUT  
%   2D DEMATEL map with pop-out labels for overlapping points.
%
%   h = plot_causal_map_v1_callout(P, C, names, ax, titleStr)
%
% Inputs:
%   P, C     – n×1 prominence & relation
%   names    – n×1 cellstr or string array
%   ax       – (opt) axes handle; new figure if empty
%   titleStr – (opt) title
%
% Output:
%   h        – handles (h(1)=scatter, rest=text & lines)

    if nargin<4 || isempty(ax)
        figure; ax = gca;
    end

    % detect “too close” pairs
    dx_th = 0.03 * range(P);
    dy_th = 0.03 * range(C);
    n     = numel(P);
    calloutIdx = false(n,1);
    for i=1:n-1
        for j=i+1:n
            if abs(P(i)-P(j))<dx_th && abs(C(i)-C(j))<dy_th
                calloutIdx(j) = true;  % pop-out the later one
            end
        end
    end

    % compute plot center & a uniform offset length
    center    = [ mean(P), mean(C) ];
    maxRange  = max(range(P), range(C));
    labelOff  = 0.05 * maxRange;    % 5% of full span

    % prepare axes
    axes(ax); cla(ax,'reset'); hold(ax,'on');
    grid(ax,'on');
    xlabel(ax,'Prominence (P)');
    ylabel(ax,'Relation (C)');
    if nargin>=5 && ~isempty(titleStr)
        title(ax,titleStr);
    end
    yline(ax,0,'k--'); 
    xline(ax,mean(P),'k--');

    % scatter all points
    h = gobjects(1,1);
    h(1) = scatter(ax, P, C, 30, 'k','filled');

    % pop-out labels + connectors
    idx = find(calloutIdx);
    for k = idx.'
        % direction from center out to point
        v = [P(k)-center(1), C(k)-center(2)];
        v = v / norm(v);

        % new label position = point + small offset outward
        labPos = [P(k), C(k)] + labelOff * v;

        % draw a light dashed connector
        plot(ax, [P(k), labPos(1)], [C(k), labPos(2)], ...
             '--', 'Color',[0.3 0.3 0.3], 'LineWidth',0.6);

        % choose text alignment based on direction
        hal = 'center'; 
        if v(1)>0,  hal='left'; 
        elseif v(1)<0, hal='right'; end
        val = 'middle';
        if v(2)>0, val='bottom'; 
        elseif v(2)<0, val='top'; end

        % place the label
        h(end+1) = text(ax, labPos(1), labPos(2), names(k), ...
                 'FontSize',8, 'FontWeight','bold', ...
                 'HorizontalAlignment', hal, ...
                 'VerticalAlignment',   val, ...
                 'BackgroundColor','none');
    end

    % draw the remaining labels right beside their points
    idx2 = find(~calloutIdx);
    dx = 0.02 * range(P);
    dy = 0.02 * range(C);
    for k = idx2.'
        h(end+1) = text(ax, P(k)+dx, C(k)+dy, names(k), ...
                 'FontSize',8, 'FontWeight','bold', ...
                 'BackgroundColor','none', ...
                 'HorizontalAlignment','left');
    end

    hold(ax,'off');
end
