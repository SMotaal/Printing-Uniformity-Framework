function r = testPerformance( obj )
  %TESTPERFORMANCE Summary of this function goes here
  %   Detailed explanation goes here
  
  t.Total                   = tic;
  
  caseIDs                   = obj.Cases.keys;
  caseCount                 = numel(caseIDs);
  
  setIDs                    = obj.setIDs;
  setCount                  = numel(setIDs);  
  setNames                  = arrayfun(@(a)num2str(a,'TV%d'), setIDs, 'UniformOutput', false); %num2str(
  
  regionModeIDs             = obj.regionModeRules(1, 1);
  regionModeCount           = numel(regionModeIDs);  
  regionModeDescription     = obj.regionModeRules(1, 3);
  
  for m = 1:caseCount
    rCase                   = struct();
    tCase                   = struct();
    tCase.Total             = tic;    
    
    caseID                  = caseIDs{m};
    
    caseData                = obj.Cases(caseID);
    
    caseName                = caseID;
    
    tCase.Set               = tic;
    obj.CaseID              = caseID;
    rCase.Set               = toc(tCase.Set);
    
    sheetIndex              = obj.CaseData.Index.Sheets;
    sheetIDs                = 1:numel(sheetIndex);
    sheetCount              = numel(sheetIDs);
    
    for n = 1:setCount
      rSet                  = struct();
      tSet                  = struct();
      tSet.Total            = tic;
      
      setID                 = setIDs(n);
      setName               = setNames{n};
      
      tSet.Set              = tic;
      obj.SetID             = setID;
      rSet.Set              = toc(tSet.Set);
      
      for p = 1 % :regionModeCount
        rMode               = struct();
        tMode               = struct();
        tMode.Total         = tic;        
        
        modeID              = regionModeIDs{p};
        modeDescription     = regionModeDescription{p};
        
        modeName            = modeID;
        
        % tMode.Set           = tic;
        % obj.RegionM
        
        for q = 1:sheetCount
          rSheet            = struct();
          tSheet            = struct();
          tSheet.Total      = tic;
          
          sheetID           = sheetIDs(q);
          sheetNumber       = sheetIndex(q);
          sheetName         = num2str(sheetNumber, 'Sheet%d');
          
          tSheet.Set        = tic;
          obj.SheetID       = q;
          rSheet.Set        = toc(tSheet.Set);
          
          rSheet.Total      = toc(tSheet.Total);
          
          tMode.(sheetName) = tSheet;
          rMode.(sheetName) = rSheet;
        end
        
        rMode.Total         = toc(tMode.Total);
        
        tSet.(modeName)     = tMode;
        rSet.(modeName)     = rMode;
      end
      
      rSet.Total            = toc(tSet.Total);
      
      tCase.(setName)       = tSet;
      rCase.(setName)       = rSet;
    end
    
    rCase.Total             = toc(tCase.Total);
    
    t.(caseName)            = tCase;
    r.(caseName)            = rCase;
    
  end
  
  r.Total                   = toc(t.Total);
  
end

