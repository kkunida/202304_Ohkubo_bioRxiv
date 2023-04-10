function vals = optInputObjective(p,Simulator,Exp) 
%%
% Update the experiments with the estimated parameter values.
Exp  = setEstimatedValues(Exp,p);
modelName = Simulator.ModelName;

%%
% Simulate the model and compare simulation output logs with measured data.

Simulator = createSimulator(Exp,Simulator);

% execute the simulation
Simulator = sim(Simulator);
    
% get the simulation Log
loggedSignalName = get_param(modelName,'SignalLoggingName');
SimLog = find(Simulator.LoggedData,loggedSignalName);

OutputLog = find(SimLog,'IPA');
vals.F = -OutputLog.Values.Data(end);    
end