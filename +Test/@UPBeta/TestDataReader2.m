function TestDataReader2()
  %TESTDATAREADER2 Summary of this function goes here
  %   Detailed explanation goes here
  
  
  GrasppeKit.DelayedCall(@(s,e)testNewReaderFunction(),[],'start');
  %testNewReaderFunction();
  
end

function testNewReaderFunction()
  
  dataReader = Grasppe.PrintUniformity.Data.DataReader( ...
    'GetVariableDataFunction', @(d)processVariableData(d), ...
    'GetSheetDataFunction', @(d, v)processSheetData(d, v), ...
    'CaseID', 'rithp5501', 'SetID', 100, 'SheetID', 5);
  
  dataReader.addlistener('CaseChange',      @updateData);
  dataReader.addlistener('SetChange',       @updateData);
  dataReader.addlistener('SheetChange',     @updateData);
  dataReader.addlistener('VariableChange',  @updateData);
  dataReader.addlistener('FailedChange',    @updateData);
  
  sheetReady = false;
  
  for m = [round(rand(1,15)*30) 150] %, disp([ x.SheetID m]);
    dataReader.SheetID = m;
    dispf('@Set:\tCase: %s\tSet: %d\tSheet: %d/%d\tDataSize: %d x %d', ...
      dataReader.Data.Parameters.CaseID, dataReader.Data.Parameters.SetID, dataReader.Data.Parameters.SheetID, dataReader.SheetID,  size(dataReader.SheetData));
    
    c = tic;
    while ~isequal(dataReader.Data.Parameters.SheetID, m) %dataReader.SheetID)
      try
        pauseTest; %pause(0.1);     
      catch err
        debugStamp(err, 1);
        throw(err);
      end
      if toc(c)>20, error('Time out!'), end
    end
  end
  
  try delete(dataReader); end
end

function pauseTest(fail, e)
  persistent failed err;
  
  if ~isempty(failed), disp(failed); end
  
  if nargin>1
    if exist('fail', 'var'),  failed  = fail;  end
    if exist('e', 'var'),     err     = e;     end
  else
    if isempty(failed) || isequal(failed, false)
      pause(0.1);
    else
      if isa(err, 'MException')
        throwAsCaller(err);
      else
        error('Grasppe:Test:GenericError', 'Test failed due to some error!');
      end
    end
  end
  
  if ~isempty(failed), disp(failed); end
  
end

function updateData(source, event)
  caseID = ''; setID = []; variableID = ''; sheetID = []; oldSheetID = [];
  sheetData = [];
  
  try caseID      = event.Data.Parameters.CaseID;     end
  try setID       = event.Data.Parameters.SetID;      end
  try variableID  = event.Data.Parameters.VariableID; end
  try sheetID     = event.Data.Parameters.SheetID;    end
  try oldSheetID  = event.OldData.Parameters.SheetID; end
  try sheetData   = event.Data.SheetData;             end
  try err         = event.Exception;                  end
  
  dispf('@%s\tCase: %s\tSet: %d\tVariable: %s\tSheet: %d/%d\tDataSize: %d x %d', ...
    event.EventName, ...
    caseID, setID, variableID, sheetID, ...
    oldSheetID, size(sheetData) ...
    );
  
  if all(isa(err, 'MException'))
    debugStamp(err, 1);
    pauseTest(true, err);
  end
end

function [variableData skip] = processVariableData(newData)
  variableData = newData.VariableData;
  
  if ~isstruct(variableData) || ~any(isfield(variableData, 'SetStats'))
    disp('Processing Set Statistics...');
    setData = [];
    
    for m = 1:numel(newData.SetData.data)
      setData(end+1, :)   = newData.SetData.data(m).zData;
    end
  end
  
  variableData.SetStats = Grasppe.Stats.DataStats(setData);
  
  skip = false;
  %disp('Processing Variable Data...');
  dispf('@Process variable:\tCase: %s\tSet: %d\tSheet: %d/%d\tDataSize: %d x %d', ...
    newData.Parameters.CaseID, newData.Parameters.SetID, newData.Parameters.SheetID, newData.DataReader.SheetID,  size(newData.SetData));
  
end

function [sheetData skip] = processSheetData(newData, variableData)
  sheetData = newData.SheetData;
  skip = false;
  disp('Processing Sheet Data...');
end

