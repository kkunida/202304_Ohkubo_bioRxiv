function [] = plotSimTA1415(Exp,expIdx)
    
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
    ylim([0 1])
    ylabel('IPTG [a.u.]')
    
    yUpperLim = [8 60];
    for outputIdx = 1:outputN
        nexttile
        plot(Exp(expIdx).OutputData(outputIdx).Values.Time,Exp(expIdx).OutputData(outputIdx).Values.Data,'ro', ... % measured output
            OutputLog{outputIdx}.Values.Time,OutputLog{outputIdx}.Values.Data,'b-');               % simulated output
        ylabel(outputNames{outputIdx});
        xlim([0 80])
        ylim([0 yUpperLim(outputIdx)])
        % legend('Measured','Simulated','Location','northwest');
    end

end