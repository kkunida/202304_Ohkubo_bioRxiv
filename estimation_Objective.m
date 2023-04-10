function vals = estimation_Objective(p,Simulator,Exp,expToUse,outputToUse,lambda) 
%
%    This function is used to compare model
%    outputs against experimental data.
%

%%
% Define a signal tracking requirement to compute how well the model output
% matches the experiment data. Configure the tracking requirement so that
% it returns the tracking error residuals (rather than the
% sum-squared-error) and does not normalize the errors.
%
r = sdo.requirements.SignalTracking;
% the output argument 'r' is sdo.requirements.SignalTracking object
% 'r' means 'requirements' which is like 'options'

r.Type      = '==';
r.Method    = 'Residuals';
r.Normalize = 'on';
% The maximum absolute value of the reference signal is used for normalization

%%
% Update the experiments with the estimated parameter values.
Exp  = setEstimatedValues(Exp,p);
modelName = Simulator.ModelName;

%%
% Simulate the model and compare simulation output logs with measured data.
Error = [];

outputN = numel(Exp(1).OutputData);
outputNames = cell(outputN);
for outputIdx = 1:outputN
    outputNames{outputIdx} = Exp(1).OutputData(outputIdx).Name;
end

for expIdx = expToUse
    % update the sdo.SimulationTest object
    Simulator = createSimulator(Exp(expIdx),Simulator);
    
    % assign the time values in Exp.OutputData to OutputTimesValues in the base
    % workspace
    OutputTimes = Exp(expIdx).OutputData(1).Values.Time;
    assignin('base','OutputTimesValues',OutputTimes);
    
    % execute the simulation
    Simulator = sim(Simulator);
    
    % get the simulation Log
    loggedSignalName = get_param(modelName,'SignalLoggingName');
    SimLog = find(Simulator.LoggedData,loggedSignalName);
    
    for outputIdx = outputToUse
        OutputLog = find(SimLog,outputNames{outputIdx});
        errorSeq = evalRequirement(r,OutputLog.Values,Exp(expIdx).OutputData(outputIdx).Values);
        Error = [Error; errorSeq];
    end
end
%%
% for regularization
pValueScaled = zeros(numel(p),1);
for paramIdx = 1:numel(p)
    if p(paramIdx).Free == 1
        pValueScaled(paramIdx) = p(paramIdx).Value/p(paramIdx).Scale - 1; 
    end
end

Error = [Error; lambda*pValueScaled];

%%
% Return the residual errors to the optimization solver.
% vals.F = Error'*Error;
vals.F = Error;
end