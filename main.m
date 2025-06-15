%====================================================================
%  main  —  Run crisp & fuzzy DEMATEL, save results
%====================================================================
clear; clc;

%% I - Import and Data Preparation

% A linguistic expert judgement table is a must. nameFile table which 
% contains names for each criteria is optional. If names are not available,
% the nameFile line below can be commented out. Imported expert judgements
% then are converted into a numerical direct matrix.

dataDir  = '/MATLAB Drive/RiskAnalysis/DEMATEL/data/';
outDir   = fullfile('output');
if ~exist(outDir,'dir'); mkdir(outDir); end


matFile  = fullfile(dataDir,'hybrid_tugboat_battery_risks_linguistic.csv');
nameFile = fullfile(dataDir,'hybrid_tugboat_battery_risks_names.csv');

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
figC = figure('Visible','off');
plot_causal_map(resC.P,resC.C,codes,[], ...
               'Crisp DEMATEL causal map');
saveas(figC,fullfile(outDir,'crisp_causal_map.png'));

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
figF = figure('Visible','off');
plot_causal_map(resF.P,resF.C,codes,[], ...
               'Fuzzy DEMATEL causal map');
saveas(figF,fullfile(outDir,'fuzzy_causal_map.png'));

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

figA = figure('Visible','off');  ax = gca;

plot_causal_map(resC.P,resC.C,codes,ax,'Crisp vs Fuzzy');
hold on
scatter(resF.P,resF.C,40,'d','filled','MarkerFaceAlpha',0.8);
text(resF.P+0.03*max(resF.P),resF.C-0.02*max(resF.C),codes + "_f",'FontSize',8);

legend({'Crisp','Fuzzy'},'Location','best');
saveas(figA,fullfile(outDir,'combined_causal_map.png'));

% Due to fuzzification and defuzzification, prominence values may be
% affected positively in fuzzy results with an offset.

% Plot another casual map with a prominence offset applied to the fuzzy
% results to indicate how relation (c) is changed.

figB = figure('Visible','off');  ax = gca;

plot_causal_map(resC.P,resC.C,codes,ax,'Crisp vs Fuzzy Shifted');
hold on

offset  = mean(resF.P) - mean(resC.P);
shifted = resF.P - offset;

scatter(shifted,resF.C,40,'d','filled','MarkerFaceAlpha',0.8);
text(shifted+0.03*max(shifted),resF.C-0.02*max(resF.C),codes + "_s",'FontSize',8);

legend({'Crisp','Fuzzy Shifted'},'Location','best');
saveas(figB,fullfile(outDir,'combined_causal_map_shifted.png'));

% Rank-stability metric

% Since prominence may seem shifted in terms of value, a spearman check
% would be in order to confirm fuzzy vs crisp consistency.

rho = corr(resC.P,resF.P,'type','Spearman');
fprintf('Correlation of crisp vs fuzzy prominence: %.4f\n',rho);

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
% fuzzy system, a heatmap is generated based on the % drop in
% total prominence. Higher values indicate more critical drivers.

figHM  = figure('Visible','off');
heatmap(colLab,rowLab,Z,'ColorbarVisible','on',...
        'Title','Fuzzy leverage % drop of Causes','Colormap',parula);
saveas(figHM,fullfile(outDir,'leverage_heatmap.png'));
