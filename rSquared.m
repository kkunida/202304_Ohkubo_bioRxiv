function R2 = rSquared(p,Simulator,Exp,expToUse,outputToUse) 
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
r.Method    = 'SSE';
r.Normalize = 'off';
% The maximum absolute value of the reference signal is used for normalization

%%
% Update the experiments with the estimated parameter values.
Exp  = setEstimatedValues(Exp,p);
modelName = Simulator.ModelName;

%%
% Simulate the model and compare simulation output logs with measured data.

outputN = numel(Exp(1).OutputData);
outputNames = cell(outputN);
for outputIdx = 1:outputN
    outputNames{outputIdx} = Exp(1).OutputData(outputIdx).Name;
end

expIdx = expToUse;
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

R2 = zeros(1,numel(outputToUse));
for outputIdx = outputToUse
    OutputLog = find(SimLog,outputNames{outputIdx});
    data = Exp(expIdx).OutputData(outputIdx).Values;
    N_missing = nnz(ismissing(data.Data));
    SSE = evalRequirement(r,OutputLog.Values,data);
    N = data.Length - N_missing;
    SST = (N - 1)*var(data);
    R2(outputIdx) = 1 - SSE/SST;
end

%%
% Return the residual errors to the optimization solver.
% vals.F = Error'*Error;
% vals.F = R2;
end