function h = plot_causal_map_cmb(resC, resF, codes, ax, titleStr, opts)
% PLOT_CAUSAL_MAP_CMB  Combined DEMATEL causal map (crisp vs fuzzy)
%   h = plot_causal_map_cmb(resC, resF, codes, ax, titleStr, opts)
% Inputs:
%   resC, resF    - structs with fields P (n×1), C (n×1), T (n×n)
%   codes         - n×1 cellstr or string array of factor codes
%   ax            - (optional) axes handle; new figure if empty
%   titleStr      - (optional) title string
%   opts          - struct with fields (all optional):
%       .colorC      - RGB for crisp markers (default [0 0.4470 0.7410])
%       .colorF      - RGB for fuzzy markers (default [0.8500 0.3250 0.0980])
%       .markerSize  - size of markers (default 20)
%       .dx_th, .dy_th - overlap thresholds (default 3% of ranges)
%       .labelOffPct - label offset pct (default 0.05)
%       .calloutAngle- angular step for multi-overlaps (rad, default pi/12)

    if nargin<4 || isempty(ax)
        figure;
        ax = gca;
    end
    if nargin<6
        opts = struct();
    end
    n = numel(codes);

    % Combine crisp & fuzzy data
    P_all = [resC.P; resF.P];
    C_all = [resC.C; resF.C];

    % Defaults
    if ~isfield(opts,'colorC'),      opts.colorC      = [0 0.4470 0.7410]; end
    if ~isfield(opts,'colorF'),      opts.colorF      = [0.8500 0.3250 0.0980]; end
    if ~isfield(opts,'markerSize'),  opts.markerSize  = 20;            end
    rngP = range(P_all); rngC = range(C_all);
    if ~isfield(opts,'dx_th'),       opts.dx_th       = 0.03 * rngP;   end
    if ~isfield(opts,'dy_th'),       opts.dy_th       = 0.03 * rngC;   end
    if ~isfield(opts,'labelOffPct'), opts.labelOffPct = 0.05;          end
    if ~isfield(opts,'calloutAngle'),opts.calloutAngle= pi/12;        end

    % Build labels with subscripts
    namesC   = string(codes) + "_c";
    namesF   = string(codes) + "_f";
    namesAll = [namesC; namesF];

    totalN = 2 * n;
    calloutIdx = false(totalN,1);
    % Detect collisions
    for i = 1:totalN-1
        for j = i+1:totalN
            if abs(P_all(i)-P_all(j)) < opts.dx_th && abs(C_all(i)-C_all(j)) < opts.dy_th
                calloutIdx(j) = true;
            end
        end
    end

    % Compute center and offset length
    center   = [mean(P_all), mean(C_all)];
    labelOff = opts.labelOffPct * max(rngP, rngC);

    % Prepare axes
    axes(ax);
    cla(ax,'reset');
    hold(ax,'on');
    grid(ax,'on');
    xlabel(ax,'Prominence (P)');
    ylabel(ax,'Relation (C)');
    if nargin>=5 && ~isempty(titleStr)
        title(ax,titleStr);
    end
    yline(ax,0,'k--');
    xline(ax,mean(P_all),'k--');

    % Plot crisp and fuzzy points
    h = gobjects();
    h(end+1) = scatter(ax, resC.P, resC.C, opts.markerSize, opts.colorC, 'filled');
    h(end+1) = scatter(ax, resF.P, resF.C, opts.markerSize, opts.colorF, 'd', 'filled');

    % Label offsets for non-callout
    dx = 0.01 * rngP;
    dy = 0.01 * rngC;

    % Callout labels (radial offset from point)
    coList = find(calloutIdx);
    for m = 1:numel(coList)
        idx = coList(m);
        baseTheta = atan2(C_all(idx)-center(2), P_all(idx)-center(1));
        prev = coList(1:m-1);
        kcol = sum(abs(P_all(prev)-P_all(idx))<opts.dx_th & abs(C_all(prev)-C_all(idx))<opts.dy_th);
        % reverse direction for fuzzy (second half)
        if idx <= n
            theta = baseTheta + kcol * opts.calloutAngle;
        else
            theta = baseTheta - kcol * opts.calloutAngle;
        end
        % offset from the point itself
        labPos = [P_all(idx), C_all(idx)] + labelOff * [cos(theta), sin(theta)];
        % connector line
        plot(ax, [P_all(idx), labPos(1)], [C_all(idx), labPos(2)], '--', ...
             'Color', [0.3 0.3 0.3], 'LineWidth', 0.6);
        % choose color
        if idx <= n
            col = opts.colorC;
        else
            col = opts.colorF;
        end
        % text label
        h(end+1) = text(ax, labPos(1), labPos(2), namesAll(idx), ...
                         'FontSize', 8, 'FontWeight', 'bold', ...
                         'Color', col, 'HorizontalAlignment', 'center', ...
                         'BackgroundColor', 'none');
    end

    % Non-callout labels
    nonCO = find(~calloutIdx);
    for idx = nonCO.'
        if idx <= n
            col = opts.colorC;
        else
            col = opts.colorF;
        end
        h(end+1) = text(ax, P_all(idx)+dx, C_all(idx)+dy, namesAll(idx), ...
                         'FontSize', 8, 'FontWeight', 'bold', ...
                         'Color', col, 'HorizontalAlignment', 'left', ...
                         'BackgroundColor', 'none');
    end

    hold(ax,'off');
end
