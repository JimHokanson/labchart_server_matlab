classdef view
    %
    %   Class:
    %   labchart.document.view
    %
    %   Improvements
    %   ------------
    %   1) Display list of methods on displaying the class
    %   2) Allow creating a default view when constructing the object
    %   or by setting the property diretly 
    
    %View States
    %"Chart View"
    %"Zoom View"
    %"Comments View"
    %"Scope View"
    %"Data Pad"
    
    properties (Hidden)
        h
    end
    
    methods
        function obj = view(h)
            obj.h = h;
        end
        %Closing Window - NYI
        %--------------
        %OpenCloseWindow(WindowId,ViewInstance,Open)
        %Closing Example 'Zoom View',1,False
        
        %View States - Partial Implemented
        %-----------
        %minimize - 61472
        %maximize - 61488
        %unmaximize - float - 61728
        %double click on window - 61490
        function maximizeView(obj,view_name)
            %
            %   Maximizes the specified view.
            %
            
            INSTANCE_ID = 1; %We may eventually make this optional
            MAXIMIZE_CMD = 61488;
            invoke(obj.h,'SetViewState',h__resolveViewName(view_name),INSTANCE_ID,MAXIMIZE_CMD)
        end
        function openView(obj,view_name)
            %
            %    Inputs
            %    ------
            %    name: string
            %        Only the first 4 characters are needed, case
            %        insensitive
            %        - 'chart view'
            %        - 'zoom view'
            %        - 'comments view'
            %        - 'scope view'
            %        - 'data pad'
            
            invoke(obj.h,'OpenView',h__resolveViewName(view_name));
        end
        function setZoomLevel(obj,zoom_level,varargin)
            %
            %
            %   Inputs
            %   ------
            %   zoom level - #
            %       In Labchart 8
            %       Values of 1,2,and 5 from 1e-1 to 1e5
            %       0.1 to 100000, 0.2 to 200000, 0.5 to 300000
            %       So for example, 20000 is also an option
            %
            %   Optional Inputs
            %   ---------------
            %
            
            in.center_on_selection = false;
            in.view_id = 'chart';
            in = labchart.sl.in.processVarargin(in,varargin);
            
            %TODO: Filter Zoom Level
            %This should be based on the Labchart Version
            invoke(obj.h,'SetRightXCompression',zoom_level,in.center_on_selection,h__resolveView(in.view_id))
        end
        function centerViewOnComment(obj,comment_id)
            %
            %This command was extracted via macro recording
            
            invoke(obj.h,'ShowComment',comment_id);
        end
    end
    
end

function output = h__resolveViewName(input_view_name)


if length(input_view_name) < 4
    error('Unsupported view')
end

switch lower(input_view_name(1:4))
    case 'char'
        output = 'Chart View';
    case 'zoom'
        output = 'Zoom View';
    case 'comm'
        output = 'Comments View';
    case 'scop'
        output = 'Scope View';
    case 'data'
        output = 'Data Pad';
    otherwise
        error('Option: %s, not regcognized as a valid view option',input_view_value)
end

end

% ?? Doc.SetViewDate("Chart View",1,62728)
%TypeId, ViewInstance, Cmd
