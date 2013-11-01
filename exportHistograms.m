% load('/Users/daflair/Documents/Workspace/MATLAB/UniformPrinting/Output/tallyData-130526.mat');

runID                   = 4;
setID                   = 1;

setData                 = Data(runID,setID);

runData                 = setData.runData;
st                      = GrasppeAlpha.Stats.TransientStats(runData);
runHist                 = st.Histogram;

sheetSize               = setData.sheetSize;
sheetData               = reshape(runData, [], prod(sheetSize));
sheetCount              = size(sheetData,1);

sheetHists              = zeros(sheetCount,100,2);
for s = 1:sheetCount
   st                   = GrasppeAlpha.Stats.TransientStats(sheetData(s, :));
   sheetHists(s, :, :)  = st.Histogram;
end

dSheetRange             = reshape(sheetHists(:,:, 1),1,[]);
dRunRange               = runHist(:,1)';
dMin                    = min([1.35 dRunRange dSheetRange 1.75]); 
dMax                    = max([1.35 dRunRange dSheetRange 1.75]);
dInterp                 = [dMin:0.01:dMax];
dSteps                  = numel(dInterp);

runCurve                = interp1(runHist(:,1), runHist(:,2), dInterp);

sheetCurves             = zeros(sheetCount, dSteps);
for s=1:sheetCount
  sheetCurves(s, :)     = interp1(sheetHists(s,:,1), sheetHists(s,:,2), dInterp);
end

allCurves               = [runCurve; sheetCurves];

[dInterp; allCurves]; openvar('ans');

