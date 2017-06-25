function plot_pr(scoreDir, methodName, numCls, plotDir, objectNames)
numMtd = length(scoreDir);
assert(length(scoreDir)==length(methodName), ...
    'Number of input dirs must be equal to input method names!');
for idxCls = 1:numCls
    fprintf('Plotting class %d precision-recall curve\n', idxCls);
    resultCatLst = cell(numMtd, 1);

    for idxMtd = 1:numMtd
        load(fullfile(scoreDir{idxMtd}, ['/class_' num2str(idxCls, '%03d') '.mat']))
        resultCatLst{idxMtd} = resultCat;
    end
    
    % plot figure
    [F_ODS, ~, ~, H] = plot_eval_multiple(resultCatLst);
    legendLst = cell(numMtd, 1);
    for idxMtd = 1:numMtd
        legendLst{idxMtd, 1} = ['[F=' num2str(F_ODS(idxMtd), '%1.3f') '] ' methodName{idxMtd, 1}];
    end
    set(gca,'fontsize',10)
    title(objectNames{idxCls},'FontSize',14,'FontWeight','bold')
    hLegend = legend(H, legendLst, 'Location', 'SouthWest');
    set(hLegend,'FontSize',10);
    xlabel('Recall','FontSize',14,'FontWeight','bold')
    ylabel('Precision','FontSize',14,'FontWeight','bold')
    
    % save figure
    print(gcf, fullfile(plotDir, ['pr_class_' num2str(idxCls, '%03d') '.pdf']),'-dpdf')
    close(gcf);
end