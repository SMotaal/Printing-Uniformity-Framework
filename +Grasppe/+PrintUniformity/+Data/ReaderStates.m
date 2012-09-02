classdef ReaderStates
  %READERSTATE Summary of this function goes here
  %   Detailed explanation goes here
  
  enumeration
    Uninitialized   (0,   'Constructing Object' )
    Initialized     (1,   'Object Constructed'  );
    
    Busy            (10,  'Is Busy',        'Initialized');
    Ready           (90,  'Not Busy',       'Initialized');
    
    Loading         (20,  'Loading',        'Initialized', 'Busy'   );
    Loaded          (40,  'Loaded',         'Initialized', 'Ready'  );
    Pasring         (60,  'Pasing',         'Initialized', 'Busy'   );
    Parsed          (60,  'Parsed',         'Initialized', 'Ready'  );
    
    CaseLoading     (120, 'Loading Case',   'Initialized',  'Loading',    'Busy'                );
    CaseLoaded      (140, 'Case Loaded',    'Initialized',  'Loaded',     'Ready'               );
    CaseParsing     (160, 'Parsing Case',   'Initialized',  'CaseLoaded', 'Pasring',    'Busy'  );
    CaseParsed      (180, 'Parsing Case',   'Initialized',  'CaseLoaded', 'Parsed',     'Ready' );
    CaseReady       (190, 'Case Ready',     'Initialized',  'CaseParsed', 'CaseLoaded', 'Ready' );
    
    SetLoading      (220, 'Loading Set',    'Initialized',  'CaseReady',  'Loading',    'Busy'                  );
    SetLoaded       (240, 'Set Loaded',     'Initialized',  'CaseReady',  'Loaded',     'Ready'                 );
    SetParsing      (260, 'Parsing Set',    'Initialized',  'CaseReady',  'SetLoaded',  'Pasring',      'Busy'  );
    SetParsed       (280, 'Parsing Set',    'Initialized',  'CaseReady',  'SetLoaded',  'Parsed',       'Ready' );
    SetReady        (290, 'Set Ready',      'Initialized',  'CaseReady',  'SetParsed',  'SetLoaded',    'Ready' );
    
    SheetLoading    (320, 'Loading Sheet',  'Initialized',  'CaseReady',  'SetReady',   'Loading',      'Busy'                  );
    SheetLoaded     (340, 'Sheet Loaded',   'Initialized',  'CaseReady',  'SetReady',   'Loaded',       'Ready'                 );
    SheetParsing    (360, 'Parsing Sheet',  'Initialized',  'CaseReady',  'SetReady',   'SheetLoaded',  'Pasring',      'Busy'  );
    SheetParsed     (380, 'Parsing Sheet',  'Initialized',  'CaseReady',  'SetReady',   'SheetLoaded',  'Parsed',       'Ready' );
    SheetReady      (390, 'Sheet Ready',    'Initialized',  'CaseReady',  'SetReady',   'SheetParsed',  'SheetLoaded',  'Ready' );
    
    
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
              dispf('enu:%s < pre:%s', enu.char, pre.char);
              error('Grasppe:Precondition:CircularReference', ...
                'Cannot create %s due to circular preconditioning with %s.', ...
                enu.char, pre.char);
            end
            if enu > pre %any(enu.Precondition==pre)
              dispf('enu:%s > pre:%s', enu.char, pre.char);
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
            
            dispf('enu:%s | pre:%s', enu.char, pre.char);
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

