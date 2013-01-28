classdef ReaderStates
  %READERSTATE Summary of this function goes here
  %   Detailed explanation goes here
  
  enumeration
    Uninitialized   (0,   'Constructing Object' )
    Initialized     (1,   'Object Constructed'  );
    
    CaseLoading     (120, 'Loading Case',   'Uninitialized',  'Initialized');
    CaseReady       (190, 'Case Ready',     'Uninitialized',  'Initialized',  'CaseLoading');
    
    SetLoading      (220, 'Loading Set',    'Uninitialized',  'Initialized',  'CaseLoading',  'CaseReady');
    SetReady        (290, 'Set Ready',      'Uninitialized',  'Initialized',  'CaseLoading',  'CaseReady',  'SetLoading');
    
    VariableLoading (320, 'Loading Set',    'Uninitialized',  'Initialized',  'CaseLoading',  'CaseReady',  'SetLoading',   'SetReady');
    VariableReady   (390, 'Set Ready',      'Uninitialized',  'Initialized',  'CaseLoading',  'CaseReady',  'SetLoading',   'SetReady',   'VariableLoading');
    
    SheetLoading    (420, 'Loading Sheet',  'Uninitialized',  'Initialized',  'CaseLoading',  'CaseReady',  'SetLoading',   'SetReady',   'VariableLoading',  'VariableReady');
    SheetReady      (490, 'Sheet Ready',    'Uninitialized',  'Initialized',  'CaseLoading',  'CaseReady',  'SetLoading',   'SetReady',   'VariableLoading',  'VariableReady',  'SheetLoading');
  end
  
  properties %(SetAccess=immutable)
    ID            = nan;
    Description   = '';
    Precondition  = eval([eval(NS.CLASS) '.empty()']);
  end
  
  methods
    function enu = ReaderStates(id, description, varargin) %busy,
      
      %enu.Busy  = isequal(busy, 1);
      enu.ID    = id;
      enu.Description = description;
      
      if numel(varargin)>0
        for m = 1:numel(varargin)
          pre = varargin{m};
          
          if ischar(pre)
            try pre = eval([eval(NS.CLASS) '.' pre]); end
          end
          
          if isa(pre, class(enu))
            if pre > enu %any(pre.Precondition==enu)
              %dispf('enu:%s < pre:%s', enu.char, pre.char);
              error('Grasppe:Precondition:CircularReference', ...
                'Cannot create %s due to circular preconditioning with %s.', ...
                enu.char, pre.char);
            end
            if enu > pre %any(enu.Precondition==pre)
              %dispf('enu:%s > pre:%s', enu.char, pre.char);
              continue;
            end
            
            %             for n = 1:numel(pre.Precondition)
            %               if pre.Precondition(n) > enu
            %                 dispf('enu:%s < pre:%s.pre:%s', enu.char, pre.char, pre.Precondition(n).char);
            %                 error('Grasppe:Precondition:CircularReference', ...
            %                   'Cannot create %s due to circular preconditioning with %s.', ...
            %                   enu.char, pre.char);
            %               else
            %                 dispf('enu:%s > pre:%s.pre:%s', enu.char, pre.char, pre.Precondition(n).char);
            %                 enu.Precondition(end+1) = pre.Precondition(n);
            %               end
            %             end
            %
            %             if any(pre.Precondition > enu)
            %               dispf('enu:%s < pre:%s.pre', enu.char, pre.char); %, pre.Precondition(find).char);
            %               error('Grasppe:Precondition:CircularReference', ...
            %                 'Cannot create %s due to circular preconditioning with %s.', ...
            %                 enu.char, pre.char);
            %             else
            %               dispf('enu:%s > pre:%s.pre:%s', enu.char, pre.char, pre.Precondition(n).char);
            %               enu.Precondition = [enu.Precondition pre.Precondition];
            %               %enu.Precondition(end+1) = pre.Precondition(n);
            %             end
            
            %dispf('enu:%s | pre:%s', enu.char, pre.char);
            enu.Precondition(end+1) = pre;
            
          end
        end
      end
    end
    
    function tf = gt(a, b)
      tf = b < a;
    end
    
    function tf = lt(a, b)
      %if ~isa(b, class(a)), tf = false, end
      if numel(a)==1
        tf = zeros(size(b));
        for m = 1:numel(b)
          tf(m) = isa(b(m), class(a)) && any(b(m).Precondition==a);
        end
      elseif numel(b)==1
        tf = zeros(size(a));
        for m = 1:numel(a)
          tf(m) = isa(b, class(a(m))) && any(b.Precondition==a(m));
        end
      elseif isequal(size(a),size(b))
        tf = zeros(size(a));
        for m = 1:numel(a)
          tf(m) = isa(b(m), class(a(m))) && any(b(m).Precondition==a(m));
        end
      else
        error('Grasppe:Size:Mismatch', 'Cannot compare matrices with different sizes.');
      end
      
      tf = tf~=0;
      %       for m = 1:numel(b.Precondition)
      %         if b.Precondition(m)==a %.ID == a.ID
      %           tf = true;
      %           return;
      %         end
      %       end
    end
    
    function tf = ge(a,b)
      tf = b <= a;
    end
    
    function tf = le(a,b)
      tf = isequal(a, b) || a < b;
    end
    
  end  
  
end

