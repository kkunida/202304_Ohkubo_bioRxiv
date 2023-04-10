function [] = plotSimTA2445_stylized(Exp,expIdx)
    
    % restore the model from Fast Restart
    modelName = Exp(1).ModelName;
    set_param(modelName,'OutputOption','RefineOutputTimes','OutputTimes','[]');

    Simulator = createSimulator(Exp(expIdx));
    Simulator = sim(Simulator);
    
    loggedSignalName = get_param(modelName,'SignalLoggingName');
    SimLog = find(Simulator.LoggedData,loggedSignalName);

    outputN = numel(Exp(1).OutputData);
    outputNames = cell(outputN);
    for outputIdx = 1:outputN
        outputNames{outputIdx} = Exp(1).OutputData(outputIdx).Name;
    end

    OutputLog = cell(3,1);
    for outputIdx = 1:outputN
        OutputLog{outputIdx} = find(SimLog,outputNames{outputIdx});
    end

    nexttile
    stairs(Exp(expIdx).InputData.Values.Time,Exp(expIdx).InputData.Values.Data,'b-');
    xlim([0 80])
    ylim([0.01 1])
    ylabel('IPTG [mM]')
    set(gca,'YScale','log')
    
    yUpperLim = [8 80];
    for outputIdx = 1:outputN
        nexttile
        p = plot( ...
            OutputLog{outputIdx}.Values.Time,OutputLog{outputIdx}.Values.Data,'b-',...
            Exp(expIdx).OutputData(outputIdx).Values.Time, ... % data 1
            Exp(expIdx).OutputData(outputIdx).Values.Data, ...
            'ko', ...
            Exp(expIdx + 5).OutputData(outputIdx).Values.Time, ... % data 2
            Exp(expIdx + 5).OutputData(outputIdx).Values.Data, ...
            'ko', ...
            Exp(expIdx + 10).OutputData(outputIdx).Values.Time, ... % data 3
            Exp(expIdx + 10).OutputData(outputIdx).Values.Data, ...
            'ko' ...
            );
        for i = 2:4
            p(i).MarkerFaceColor = 'w';
            p(i).MarkerSize = 4;
        end
        ylabel(outputNames{outputIdx});
        xlim([0 80])
        ylim([0 yUpperLim(outputIdx)])
        % legend('Measured','Simulated','Location','northwest');
    end

end