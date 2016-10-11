classdef view < handle
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
    
    properties
        last_zoom_level %containers.Map
        %keys are the view names
        %values are the previous zoom levels
    end
    
    methods
        function obj = view(h)
            obj.last_zoom_level = containers.Map();
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
        function maximizeView(obj,varargin)
            %
            %   Maximizes the specified view.
            %
            
            in.view_name = 'chart';
            in = labchart.sl.in.processVarargin(in,varargin);
            
            INSTANCE_ID = 1; %We may eventually make this optional
            MAXIMIZE_CMD = 61488;
            invoke(obj.h,'SetViewState',h__resolveViewName(in.view_name),INSTANCE_ID,MAXIMIZE_CMD);
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
            %   delta_zoom : numeric (default empty)
            %       +1 - zooms in 1 level, e.g. 1000 to 500
            %       -1 - zooms out 1 level, e.g.g 1000 to 2000
            %       -2 - zooms out 2 levels, e.g. 1000 to 5000
            %       etc .
            %       This feature is currently dependent on having
            %       previously used this function to set an explicit
            %       zoom level
            %   center_on_selection : logical (default false)
            %       TODO: I'm not really sure what this means
            %       I think this means:
            %           if true, the zoom first centers on the selection
            %           then zooms appropriately (i.e. a time shift occurs)
            %           if false, the center of the window is used as the 
            %           reference point, and the zoom occurs (i.e. the 
            %           same time stays at the center)
            %   view_id : (default 'chart')
            %       Name of the window to zoom in or out on
            
            %TODO: This should be based on the Labchart version
            %This is for V8
            %V7 does not have this many view options
            ZOOM_NUMBERS = ([1 2 5])';
            ZOOM_SCALES  = (10.^(-1:5));
            ZOOM_LEVELS  = ZOOM_NUMBERS*ZOOM_SCALES;
            ZOOM_LEVELS  = ZOOM_LEVELS(:)';
            
            in.delta_zoom = [];
            in.center_on_selection = false;
            in.view_id = 'chart';
            in = labchart.sl.in.processVarargin(in,varargin);
            
            resolved_view = h__resolveViewName(in.view_id);
            
            if isempty(zoom_level)
                if ~isempty(in.delta_zoom)
                    if ~obj.last_zoom_level.isKey(resolved_view)
                        warning('The current zoom state of the document is unknown')
                        return
                    else
                        I = find(obj.last_zoom_level(resolved_view) == ZOOM_LEVELS,1);
                        if isempty(I)
                            warning('Previous zoom level is not recognized as being a valid zoom level')
                            return
                        else
                           I2 = I - in.delta_zoom;
                           if I2 < 1
                               %? throw a warning
                               if I == 1
                                   return %nothing to do
                               end
                               I2 = 1;
                           elseif I2 > length(ZOOM_LEVELS)
                               if I == length(ZOOM_LEVELS)
                                   return %nothing to do
                               end
                               I2 = length(ZOOM_LEVELS);
                           end
                           zoom_level = ZOOM_LEVELS(I2);
                        end
                    end
                else
                    error('If the zoom level is empty, a delta zoom must be specified')
                end
            end
                    
            %TODO: Filter Zoom Level
            %This should be based on the Labchart Version
            
            invoke(obj.h,'SetRightXCompression',zoom_level,in.center_on_selection,resolved_view);
            obj.last_zoom_level(resolved_view) = zoom_level;
        end
        function centerViewOnComment(obj,comment_id)
            %
            %This command was extracted via macro recording
            %   
            %   Inputs
            %   ------
            %   comment_id : number
            %       This is the ID associated with the comment. It is NOT
            %       the index of the comments in the list of comments.
            
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
