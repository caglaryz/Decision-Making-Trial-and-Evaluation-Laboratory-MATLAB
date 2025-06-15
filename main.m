%====================================================================
%  main  —  import, analyze, plot, save
%====================================================================
clear; clc;
scr = get(0,'ScreenSize');    
frac = 0.8;                   
figW = frac * scr(3);
figH = frac * scr(4);
figX = (scr(3) - figW)/2;
figY = (scr(4) - figH)/2;
%% I - Import and Data Preparation

% A linguistic expert judgement table is a must. nameFile table which 
% contains names for each criteria is optional. If names are not available,
% the nameFile line below can be commented out. Imported expert judgements
% then are converted into a numerical direct matrix.

dataDir  = '\datadirectory';
outDir   = fullfile('output');
if ~exist(outDir,'dir'); mkdir(outDir); end

matFile  = fullfile(dataDir,'your_linguistic_relations.csv');
nameFile = fullfile(dataDir,'your_factor_names.csv');

[A,codes,desc] = load_direct_matrix(matFile,nameFile);
%% II - Crisp DEMATEL

% Crisp DEMATEL as proposed by Fontela & Gabus (1973), normalises
% the expert judgement matrix and computes total-relation matrix.
% Then, prominence (P) and relation (C) values are calculated for each
% factor. Based on the sign of relation, each factor is categorised as
% Cause (C > 0) or Effect (C < 0).

% Obtain crisp DEMATEL results
resC = dematel_crisp(A);

% Total relation matrix T for crisp DEMATEL
disp('--- CRISP TOTAL RELATION MATRIX T ---');
T_Crisp = array2table(resC.T,'VariableNames',codes,'RowNames',codes);
disp(T_Crisp);
writetable(T_Crisp,fullfile(outDir,'crisp_total_relation.csv'),'WriteRowNames',true);

% Plot the causal map for crisp DEMATEL
figC = figure( 'Units','pixels','Position',[figX figY figW figH],'Visible','on' );
ax = gca;
plot_causal_map_v1_callout(resC.P, resC.C, codes, ax, 'Crisp DEMATEL Causal Map');
saveas(figC, fullfile(outDir,'crisp_causal_map.png'));

% Full Crisp DEMATEL map with alpha scaling & weights
opts = struct();
opts.curvature   = 0.3;                    % slightly more bow
opts.alphaRange  = [0.02 0.5];             % weak→very faint, strong→half-opaque
opts.showWeights = true;                   % turn on numeric labels
opts.weightFmt   = '%.2f';                 
opts.weightCutoff= prctile(abs(resC.T(:)),75);  % only label top-50% links
opts.cmap        = lines(numel(codes));    % distinct colour per factor

figCFM = figure( 'Units','pixels','Position',[figX figY figW figH],'Visible','on' );
ax = gca;
plot_causal_map_full(resC.P, resC.C, codes, ax,'Crisp DEMATEL Full Map', resC.T, opts );
saveas(figCFM, fullfile(outDir,'crisp_full_map.png'));


% Display result table for crisp DEMATEL
tblC = table(desc,resC.P,resC.C,resC.role,...
            'VariableNames',{'Factor','Prominence','Relation','Group'},'RowNames',codes);
disp('--- CRISP DEMATEL RESULTS ---');
disp(tblC);
writetable(tblC,fullfile(outDir,'crisp_results.csv'));

%% III - Fuzzy DEMATEL

% Fuzzy DEMATEL is used to represent the uncertainty of expert judgments.
% Each linguistic value is mapped to a triangular fuzzy number (TFN).
% The method used is Lin & Wu (2008), and total-relation matrix is calculated
% for each slice (low, mid, upper). Finally, the matrices are defuzzified
% using CFCS method to produce a crisp equivalent.

% Obtain fuzzy DEMATEL results
resF = dematel_fuzzy(A);

% Total relation matrix T for fuzzy DEMATEL
disp('--- FUZZY TOTAL RELATION MATRIX T (defuzzified) ---');
T_Fuzzy = array2table(resF.T,'VariableNames',codes,'RowNames',codes);
disp(T_Fuzzy);
writetable(T_Fuzzy,fullfile(outDir,'fuzzy_total_relation.csv'),'WriteRowNames',true);

% Plot the causal map for fuzzy DEMATEL
figF = figure( 'Units','pixels','Position',[figX figY figW figH],'Visible','on' );
ax = gca;
plot_causal_map_v1_callout(resF.P, resF.C, codes, ax, 'Fuzzy DEMATEL Causal Map' );
saveas(figF, fullfile(outDir,'fuzzy_causal_map.png'));

% Full Fuzzy DEMATEL map with alpha scaling & weights
opts = struct();
opts.curvature   = 0.3;                    % slightly more bow
opts.alphaRange  = [0.02 0.5];             % weak→very faint, strong→half-opaque
opts.showWeights = true;                   % turn on numeric labels
opts.weightFmt   = '%.2f';                 
opts.weightCutoff= prctile(abs(resF.T(:)),75);  % only label top-50% links
opts.cmap        = lines(numel(codes));    % distinct colour per factor

figFFM = figure( 'Units','pixels','Position',[figX figY figW figH],'Visible','on' );
ax = gca;
plot_causal_map_full( ...
  resF.P, resF.C, codes, ax, ...
  'Fuzzy DEMATEL Full Map', ...
  resF.T, opts );
saveas(figFFM, fullfile(outDir,'fuzzy_full_map.png'));

% Display result table for fuzzy DEMATEL
tblF = table(desc,resF.P,resF.C,resF.role,...
            'VariableNames',{'Factor','Prominence','Relation','Group'},'RowNames',codes);
disp('--- FUZZY DEMATEL RESULTS ---');
disp(tblF);
writetable(tblF,fullfile(outDir,'fuzzy_results.csv'));

%% IV - Analysis of Results

% Plot a causal map that includes both crisp and fuzzy results
% for a visual comparison of Prominence (P) and Relation (C).
% Crisp values are plotted as dots, fuzzy values as diamonds.
% This comparison highlights possible shifts in the evaluation
% due to fuzzification and defuzzification.

% figA = figure('Visible','off');  ax = gca;
% 
% plot_causal_map(resC.P,resC.C,codes,ax,'Crisp vs Fuzzy');
% hold on
% scatter(resF.P,resF.C,40,'d','filled','MarkerFaceAlpha',0.8);
% text(resF.P+0.03*max(resF.P),resF.C-0.02*max(resF.C),codes + "_f",'FontSize',8);
% 
% legend({'Crisp','Fuzzy'},'Location','best');
% saveas(figA,fullfile(outDir,'combined_causal_map.png'));

figC = figure( 'Units','pixels','Position',[figX figY figW figH],'Visible','on' );
ax = gca;

opts = struct();
opts.colorC      = [0 0.5 0.8];    % blue for crisp
opts.colorF      = [0.9 0.3 0.1];  % red for fuzzy
opts.markerSize  = 50;             % larger markers
opts.labelOffPct = 0.06;           % pop labels 6% outward
opts.calloutAngle= pi/10;          % bigger angle steps for multiple overlaps

h1 = plot_causal_map_cmb( resC, resF, codes, ax, 'Crisp vs Fuzzy DEMATEL', opts );
saveas(figC, fullfile(outDir,'combined_causal_map.png'));

% Due to fuzzification and defuzzification, prominence values may be
% affected positively in fuzzy results with an offset.

% Plot another casual map with a prominence offset applied to the fuzzy
% results to indicate how relation (c) is changed.

offset  = mean(resF.P) - mean(resC.P);
shifted = resF;
shifted.P = resF.P - offset;

figCS = figure( 'Units','pixels','Position',[figX figY figW figH],'Visible','on' );
ax = gca;

opts = struct();
opts.colorC      = [0 0.5 0.8];    % blue for crisp
opts.colorF      = [0.9 0.3 0.1];  % red for fuzzy
opts.markerSize  = 50;             % larger markers
opts.labelOffPct = 0.1;           % pop labels 10% outward
opts.calloutAngle= pi/10;          % bigger angle steps for multiple overlaps

h2 = plot_causal_map_cmb( resC, shifted, codes, ax, 'Crisp vs Fuzzy DEMATEL (Fuzzy Shifted)', opts );
saveas(figCS, fullfile(outDir,'combined_shifted_causal_map.png'));

% Rank-stability metric

% Since prominence may seem shifted in terms of value, a spearman check
% would be in order to confirm fuzzy vs crisp consistency.

rho = corr(resC.P,resF.P,'type','Spearman');
fprintf('Correlation of crisp vs fuzzy prominence: %.4f\n',rho);

%% V - Driver Knockout Leverage Analysis

% A driver knockout analysis is performed to evaluate how much
% each driver (C > 0) contributes to the overall prominence score.
% For each driver, its outgoing links are zeroed and the new total
% prominence is compared to the base case. This is done for both
% crisp and fuzzy results.

% Determine cause factors
isCause = resC.C > 0;

% Call helper function appropriately c|f
dlC = driver_knockout(A,resC.P,"crisp");
dlF = driver_knockout(A,resF.P,"fuzzy");

levTbl = table(desc,dlC,dlF,isCause,...
        'VariableNames',{'Factor','dC','dF','Cause'},'RowNames',codes);
levTbl = levTbl(isCause,:);
disp('--- DRIVER LEVERAGE (% drop in total P) ---');
disp(levTbl);
writetable(levTbl,fullfile(outDir,'driver_leverage.csv'));

% Plot a heat-map of fuzzy leverage
rowLab = categorical("drop");                     % single y-label
colLab = categorical(levTbl.Factor);              % x-labels
Z      = 100*levTbl.dF.';                         % 1×N row vector

% To better understand how much leverage each cause has in the
% fuzzy system, plot grouped bars for each cause crisp and fuzzy

% after computing dlC and dlF for causes only:
causeIdx = find(isCause);
dropsC   = dlC(causeIdx)*100;   % percent
dropsF   = dlF(causeIdx)*100;
namesC   = codes(causeIdx);

% sort by crisp drop descending
[~, ord] = sort(dropsC,'descend');
sortedNames = namesC(ord);
sortedC     = dropsC(ord);
sortedF     = dropsF(ord);

% Grouped Bar
figDK1 = figure( 'Units','pixels','Position',[figX figY figW figH],'Visible','on' );
bar(categorical(sortedNames), [sortedC, sortedF], 'grouped');
ylabel('% drop in total P');
title('Driver leverage: Crisp vs Fuzzy');
legend({'Crisp','Fuzzy'}, 'Location','best');
xtickangle(45);
grid on;

set(figDK1,'PaperPositionMode','auto');
print(figDK1,'-dpng','-r0', fullfile(outDir,'driver_leverage_grouped.png'));

delta = sortedF - sortedC;   % fuzzy drop > crisp drop

% Scatter of Delta Leverge (Fuzzy minus Crisp)
figDK2 = figure( 'Units','pixels','Position',[figX figY figW figH],'Visible','on' );
scatter(sortedC, delta, 80, 'filled');
xlabel('Crisp drop (%)');
ylabel('Δ drop (Fuzzy – Crisp) (%)');
title('Change in Leverage from Crisp to Fuzzy');
grid on;
hold on;
% annotate each point with its factor code
for k = 1:numel(sortedNames)
    text(sortedC(k)+0.5, delta(k), sortedNames(k), ...
         'FontSize',8, 'FontWeight','bold');
end
hold off;
set(figDK2,'PaperPositionMode','auto');
print(figDK2,'-dpng','-r0', fullfile(outDir,'driver_leverage_delta.png'));
