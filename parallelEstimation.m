function [pOpt,optInfo] = parallelEstimation(p,options,Exp,Simulator,condIdx)
    outputToUse = 1:2; % fixed
    lambda = 0; % fixed

    pOpts = cell(5,1); % 15 datasets
    optInfos = cell(5,1); % 15 datasets
    
    modelName = Exp(1).ModelName
    open_system(modelName)

    
    validSet = [condIdx, condIdx + 5, condIdx + 10]
    trainSet = setdiff(1:15,validSet)
    estFcn = @(p) estimation_Objective(p,Simulator,Exp,trainSet,outputToUse,lambda);
    tic
    [pOpt,optInfo] = sdo.optimize(estFcn,p,options)
    toc
%     pOpts{condIdx,1} = pOpt;
%     optInfos{condIdx,1} = optInfo;
    estimationFinished = condIdx
    
end