classdef AbstractSetModel < containers.Map
  %SAMPLESET Summary of this class goes here
  %   Detailed explanation goes here
  
  properties(Hidden, Dependent)
    Samples
  end
  
  properties(SetAccess=protected, GetAccess=protected)
    samples
  end
  
  methods
    function obj = AbstractSetModel(varargin)
      % try disp({varargin{1}{:}; varargin{2}{:}}); end
      % try disp(['AbstractSet: ' toString(varargin{1})]); end
      
      try
        if iscell(varargin{1}) && iscell(varargin{2}) && ...
            isequal(size(varargin{1}),size(varargin{2}))
          setKeys               = varargin{1};
          setEntries            = varargin{2};
          
          for m = 1:numel(setEntries)
            setEntries{m}.Key   = setKeys{m};
            if ~isobject(setEntries{m}) || ~isa(setEntries{m}, 'GrasppeAlpha.Data.Models.SimpleDataModel')
              setEntries{m}     = GrasppeAlpha.Data.Models.SimpleDataModel(setEntries{m});
            end
          end
          
          options               = {setKeys, setEntries};
        else
          options               = varargin;
        end
      catch err
        debugStamp(err);
      end
      
      obj                       = obj@containers.Map(options{:});
    end
    
    function samples = get.Samples(obj)
      samples                   = obj.values;
      try samples               = [samples{:}]; end
    end
    
    function sample = Sample(obj, index)
      sample                    = [obj.values{index}];
    end
    
    %     function varargout = subsref(a,s)
    %       n                       = 1:nargout;
    %       try
    %         if isequal(s(1).type, '.') && ismethod(a, s(1).subs)
    %           if isempty(n)
    %             builtin('subsref', a, s);
    %           else
    %             [varargout{n}]  = builtin('subsref', a, s);
    %           end
    %         else
    %           if isempty(n)
    %             x                 = subsref@containers.Map(a, s);    % b   = builtin('subsref', a, s);
    %           else
    %             [varargout{n}]    = subsref@containers.Map(a, s);    % b   = builtin('subsref', a, s);
    %           end
    %         end
    %       catch err
    %         if ~strcmp(err.identifier, 'MATLAB:nonExistentField')
    %           try debugStamp(err.message, 1); catch, debugStamp(); end; rethrow(err);
    %         end
    %       end
    %     end
    %   try
    %     % try
    %     % if nargout > 0
    %     if isequal(s(1).type, '.') && ~isprop(a, s(1).subs) % && ~ismethod(a, s(1).subs)
    %       if nargout > 0  % if ismethod(a, s(1).subs)
    %         [varargout{n}]  = builtin('subsref', a, s);
    %       else
    %         builtin('subsref', a, s);
    %       end
    %     else
    %       [varargout{n}]    = subsref@containers.Map(a, s);    % b   = builtin('subsref', a, s);
    %     end
    %     % else
    %     %   subsref@containers.Map(a, s);
    %     % end
    %     % catch err
    %     %   % if nargout > 0
    %     %   [varargout{n}]      = subsref@containers.Map(a, s);    % b   = subsref(a.DATA, s);
    %     %   % else
    %     %   %   subsref@containers.Map(a, s);
    %     %   % end
    %     %         end
    %   catch err
    %     if ~strcmp(err.identifier, 'MATLAB:nonExistentField')
    %       try debugStamp(err.message, 1); catch, debugStamp(); end; rethrow(err);
    %     end
    %   end
    % end
    %
    % function a = subsasgn(a,s,b)
    %   try
    %     try
    %       if isequal(s(1).type, '.') && ~isprop(a, s(1).subs) && ~ismethod(a, s(1).subs)
    %         keys              = a.keys;
    %       else
    %         a                 = subsasgn@containers.Map(a, s, b);       % a = builtin('subsasgn', a, s, b);
    %       end
    %     catch err
    %       a                   = subsasgn@containers.Map(a, s, b);       % a.DATA = subsasgn(a.DATA, s, b);
    %     end
    %   catch err
    %     try debugStamp(err.message, 1); catch, debugStamp(); end; rethrow(err);
    %   end
    %
    %
    % end
    
  end
  
end

