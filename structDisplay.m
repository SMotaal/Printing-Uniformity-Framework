function outputString = structDisplay( s, level, parent, varargin )
  %STRUCTTREE Recursively Display Structs
  %   Detailed explanation goes here
  
  if ~exist('level', 'var') || ~isscalar(level) || ~isnumeric(level)
    level                           = 0;
  end
  
  levelLimit                        = 3;
  
  if level > levelLimit, outputString        = ''; return;  end
  
  if ~exist('parent', 'var') || ~ischar(parent)
    parent                          = '';
    if isequal(level, 0), parent    = inputname(1); end
  end
  
  parentStr                         = parent;
  if ~isempty(parentStr), parentStr       = [parentStr '.']; end
  
  offset                            = '';
  
  source                            = s;
  
  %% Convert Object to Struct
  if isobject(source)
    
    S                               = warning('off', 'MATLAB:structOnObject');
    try source                      = struct(source); end
    warning(S);
    
    newSource                       = struct;
    
    fieldNames                      = fieldnames(s);
    fieldLength                     = numel(fieldNames);
    
    for m = 1:fieldLength
      fieldName                     = fieldNames{m};
      fieldValue                    = [];
      try fieldValue                = source.(fieldName); end
      newSource.(fieldName)         = fieldValue;
    end
    
    source                          = newSource;
    %     if isa(s, 'Grasppe.Prototypes.DynamicDelegator')
    %       source                        = struct('Delegate', )
    %     end
    
  end
  
  if isempty(source), outputString  = ''; return; end
  
  fieldNames                        = fieldnames(source);
  fieldLength                       = numel(fieldNames);
  
  if level>levelLimit-1 && fieldLength > 5,    outputString	= ''; return;  end
  
  valueFields                     = struct();
  structFields                    = struct();
  structStrings                   = cell(fieldLength, 1);
  structFieldsIndex               = [];
  %% Segregate Fields
  for m = 1:fieldLength
    try
      
      fieldName                   = fieldNames{m};
      fieldValue                  = source.(fieldName);
      
      isStruct                    = isstruct(fieldValue);
      isScalar                    = true; % isscalar(fieldValue);
      isObject                    = isobject(fieldValue);
      isDelegate                  = isObject && isa(fieldValue, 'Grasppe.Prototypes.DynamicDelegator'); % isScalar
      isStructure                 = isObject && isa(fieldValue, 'Grasppe.Prototypes.Models.Structure');
      isModel                     = isObject && isa(fieldValue, 'Grasppe.Prototypes.Model');
      %       isObject                    = isDelegate || isStructure ...
      %         (isScalar && isobject(fieldValue) && numel(fieldnames(fieldValue))<10);
      
      isRecusive                  = (isStruct || isDelegate || isStructure || isModel); %&& ~isDelegate
      isZeroLength                = numel(fieldValue)==0 || ((isRecusive || isObject) && numel(fieldnames(fieldValue))==0);
      
      valueFields.(fieldName)     = fieldValue;
      
      if isRecusive && ~isZeroLength
        
        if numel(varargin)>0
          parentStrMatch          = cellfun(@(x)isequal(x, fieldValue), varargin);
          if any(parentStrMatch), valueFields.(fieldName) = '...'; continue; end
        end
        
        if level<1
          subOptions              = {level+1, fieldName,  varargin{:}, s}; % [parentStr fieldName]
        else
          subOptions              = {level+1, '',  varargin{:}, s};
        end
        
        if isDelegate
          structString            = structDisplay(fieldValue.Delegate,    subOptions{:});
        elseif isStructure
          structString            = structDisplay(fieldValue.asStruct(),  subOptions{:});
        elseif isModel
          structString            = structDisplay(fieldValue.asStruct(),  subOptions{:});
        else
          structString            = structDisplay(fieldValue,             subOptions{:});
        end
        
        newString                 = structString(1:end-1);
        offset                    = max([0 find(newString==':', 1, 'first')]);
        lead                      = max([0 min(cellfun(@numel, regexp(newString, ['(?m)^[^\s]{1,' int2str(offset) '}'], 'match')))-1]);
        
        newString                 = regexprep(newString, ['(?m)^[\s]{0,' int2str(lead) '}'], '');
        newString                 = regexprep(newString, ['(?m)^(\s{0,' int2str(offset) '})([^\:]+\:)'], '$2$1');
        
        % disp([offset lead]);  disp(newString);
        
        structStrings{m}          = newString; %  sprintf(regexprep([offset structString(1:end-1)], '\n', ['\n' offset]));
        
        % valueFields.(fieldName)   = s.(fieldName);
        
        %         end
        %       end
        %       elseif isobject(fieldValue)
        %         valueFields.(fieldName)   = [num2str(size(fieldValue), '%d,') ' ' class(fieldValue) ']'];
      end
      
      %       if isa(fieldValue, 'Grasppe.Prototypes.DynamicDelegator')
      %         valueFields.(fieldName) = fieldValue;
      %       end
    catch err
      debugStamp(err, 1);
      continue;
    end
  end
  
  try
    
    %% Generate Display String
    valuesString                    = evalc('disp(valueFields)');
    valuesString                    = regexprep(valuesString, ['(?m)^(\s)*'], ['$1' parentStr]);
    valueStrings                    = regexp(valuesString, '[^\n]*', 'match');
    
    labelOffset                     = ' ';
    S                               = warning('off', 'MATLAB:NonScalarInput');
    try labelOffset                 = blanks(strfind(valueStrings{1}, ':')+1); end
    warning(S);
    
    for m = 1:fieldLength
      fieldName                     = fieldNames{m};
      fieldValue                    = source.(fieldName);
      valueString                   = valueStrings{m};          % valueString                   = regexprep(valueString, '(^\s*)', ['$1']); %parentStr
      structString                  = structStrings{m};
      
      if ischar(structString) && ~isempty(structString)
        newString                   = structString;
        
        newString                   = regexprep(newString, ['(?m)^(.)'], ['|' labelOffset '$1']);
        % disp(numel(labelOffset)); disp(newString);
        if level>0
          valueString               = sprintf('<a href="matlab:">%s</a>\n%s', valueString, newString);
        else
          valueString               = sprintf('%s\n%s', valueString, newString);
        end
      end
      valueStrings{m}               = valueString;
    end
  catch err
    debugStamp(err, 1);
  end
  
  %   if displayOffsetLength>0
  %     offset                        = repmat(' ', 1, displayOffsetLength);
  %     for m = 1:fieldLength
  % %       structString                = structStrings{m};
  % %       if ~ischar(structString)
  %         valueStrings{m}           = sprintf(regexprep([offset valueStrings{m}(1:end-1)], '(^|\n)', ['$1' offset]));
  %       end
  % %     end
  %   end
  
  %% Process Output
  outputString                    = sprintf('%s\n', valueStrings{:});
  
  if level == 0;
    outputString                  = regexprep(outputString(1:end-1), '(?m)(?<=^[\W]*)(\|)', '');
  end
  
  if nargout==0
    if ischar(parent) && ~isempty(parent)
      dispf('   %s: <a href="matlab:help %s">%s</a>\n', parent, class(s), class(s));
    end
    disp(outputString)
    clear outputString;
  end
  
end

