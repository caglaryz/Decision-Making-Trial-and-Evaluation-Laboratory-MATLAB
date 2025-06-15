function h = plot_causal_map_full(P, C, names, ax, titleStr, R, opts)
% PLOT_CAUSAL_MAP_FULL  2D DEMATEL map with alpha-scaled edges, weights, and callout labels
%
%   h = plot_causal_map_full(P, C, names, ax, titleStr, R, opts)
%
% Inputs:
%   P, C      - n×1 Prominence & Relation vectors
%   names     - n×1 cellstr or string array of factor labels
%   ax        - (optional) axes handle; new figure if empty
%   titleStr  - (optional) title string
%   R         - n×n total-relation matrix
%   opts      - struct with fields (all optional):
%       .alphaRange   - [minAlpha maxAlpha] for edges (default [0.05 0.6])
%       .showWeights  - true|false to label weights (default false)
%       .weightFmt    - sprintf format for weights (default '%.2f')
%       .weightCutoff - abs(R) cutoff for weight labels (default 0)
%       .curvature    - bow factor for arrows (default 0.2)
%       .cmap         - n×3 colormap for factors (default lines(n))
%       .dx_th, .dy_th- thresholds for overlap callouts (default 3% of data range)
%       .labelOffPct  - radial offset pct for callouts (default 0.05)
%       .calloutAngle - angle step for multi-overlaps (default pi/12)

    %--- setup inputs ---
    if nargin<4 || isempty(ax), figure; ax = gca; end
    if nargin<7, opts = struct(); end
    n = numel(P);

    %--- defaults ---
    if ~isfield(opts,'alphaRange'),   opts.alphaRange   = [0.05 0.6]; end
    if ~isfield(opts,'showWeights'),  opts.showWeights  = false;      end
    if ~isfield(opts,'weightFmt'),    opts.weightFmt    = '%.2f';    end
    if ~isfield(opts,'weightCutoff'), opts.weightCutoff = 0;         end
    if ~isfield(opts,'curvature'),    opts.curvature    = 0.2;       end
    if ~isfield(opts,'cmap') || size(opts.cmap,1)~=n
        opts.cmap = lines(n);
    end
    % compute ranges for callout thresholds
    rngP = range(P); rngC = range(C);
    if ~isfield(opts,'dx_th'),       opts.dx_th       = 0.03 * rngP; end
    if ~isfield(opts,'dy_th'),       opts.dy_th       = 0.03 * rngC; end
    if ~isfield(opts,'labelOffPct'), opts.labelOffPct = 0.05;        end
    if ~isfield(opts,'calloutAngle'),opts.calloutAngle= pi/12;      end

    %--- precompute alpha scaling ---
    Rabs = abs(R(:));
    Rmin = min(Rabs); Rmax = max(Rabs);
    if Rmax==Rmin, Rmax = Rmin + eps; end

    %--- prepare axes ---
    axes(ax); cla(ax,'reset'); hold(ax,'on');
    xlabel(ax,'Prominence (P)'); ylabel(ax,'Relation (C)');
    if nargin>4 && ~isempty(titleStr), title(ax,titleStr); end
    yline(ax,0,'k--'); xline(ax,mean(P),'k--');

    %--- draw arrows ---
    for i = 1:n
      base = opts.cmap(i,:);
      for j = 1:n
        w = R(i,j);
        a_norm = (abs(w)-Rmin)/(Rmax-Rmin);
        alphaVal = opts.alphaRange(1) + a_norm*(opts.alphaRange(2)-opts.alphaRange(1));
        col = [base alphaVal];

        p1 = [P(i), C(i)];
        p3 = [P(j), C(j)];
        d  = p3 - p1;
        ctrl = (opts.curvature/norm(d)) * ([0 -1;1 0] * d.');
        mid  = (p1 + p3)/2 + ctrl.';

        t  = linspace(0,1,30).';
        curve = (1-t).^2 .* p1 + 2*(1-t).*t .* mid + t.^2 .* p3;
        plot(ax, curve(:,1), curve(:,2), 'Color',col, 'LineWidth',1);

        k = round(0.9*size(curve,1));
        v = curve(k+1,:) - curve(k,:);
        quiver(ax, curve(k,1), curve(k,2), v(1), v(2), 0, 'Color',col, 'MaxHeadSize',1);

        if opts.showWeights && abs(w) > opts.weightCutoff
          km = round(0.5*size(curve,1));
          % use base RGB color (no alpha) to match arrow
          txtCol = base;
          text(curve(km,1), curve(km,2), sprintf(opts.weightFmt,w), ...
               'FontSize',6, 'HorizontalAlignment','center', ...
               'Color', txtCol, 'BackgroundColor','none');
        end
      end
    end

    %--- detect overlaps for callouts ---
    calloutIdx = false(n,1);
    for i = 1:n-1
      for j = i+1:n
        if abs(P(i)-P(j))<opts.dx_th && abs(C(i)-C(j))<opts.dy_th
          calloutIdx(j) = true;
        end
      end
    end

    %--- draw scatter ---
    h = gobjects();
    h(1) = scatter(ax, P, C, 20, 'k','filled');

    %--- callout labels ---
    center = [mean(P), mean(C)];
    labelOff = opts.labelOffPct * max(rngP, rngC);
    co = find(calloutIdx);
    for m = 1:numel(co)
      i = co(m);
      baseTheta = atan2(C(i)-center(2), P(i)-center(1));
      prev = co(1:m-1);
      kcol = sum(abs(P(prev)-P(i))<opts.dx_th & abs(C(prev)-C(i))<opts.dy_th);
      theta = baseTheta + kcol*opts.calloutAngle;
      labPos = [P(i), C(i)] + labelOff*[cos(theta), sin(theta)];
      plot(ax, [P(i),labPos(1)], [C(i),labPos(2)], '--', 'Color',[0.3 0.3 0.3], 'LineWidth',0.6);
      h(end+1) = text(ax, labPos(1), labPos(2), names(i), 'FontSize',8, 'FontWeight','bold', ...
                       'HorizontalAlignment','center', 'BackgroundColor','none');
    end

    %--- normal labels ---
    for i = find(~calloutIdx).'
      h(end+1) = text(ax, P(i)+0.015*rngP, C(i)+0.015*rngC, names(i), ...
                       'FontSize',8, 'FontWeight','bold', 'BackgroundColor','none');
    end

        %--- legend for factor colors ---
    legH = gobjects(n,1);
    legendMarkerSize = 10;  % fixed size for legend symbols
    for iFactor = 1:n
        legH(iFactor) = plot(ax, nan, nan, 'o', ...
            'MarkerSize', legendMarkerSize, ...
            'MarkerFaceColor', opts.cmap(iFactor,:), ...
            'Color', opts.cmap(iFactor,:));
    end
    legend(ax, legH, names, 'Location','eastoutside', 'NumColumns',1);

    hold(ax,'off');
end
