classdef doc_events < handle
    %
    %   Class:
    %   labchart.document.doc_events
    
    
    %{
    % arguments must be passed to the MATLAB file in the following order
%1 - object (com,progid) - vals{2}
%2 - event id - vals{3}
%(3:end-2) - event args - vals{4:end}
%end-1 args - all of above for users to know about event args names
%end - event name - vals{1}
    
    More than 4 args:
        feval(userMfileName, vals{2}, vals{3}, vals{4:end}, args, vals{1});
    Otherwise:
        feval(userMfileName, vals{2}, vals{3}, args, vals{1});
    %}
    
    
    %{
    lc = labchart;
    d = lc.active_document;
    em = d.event_manager;
    em.on_selection_change = @em.testCallback;
    em.on_selection_change = [];
    em.on_selection_change = @(varargin)disp('I ran!');
    %}
    
    %{
	OnStartSampling = void OnStartSampling()
	OnStartSamplingBlock = void OnStartSamplingBlock()
	OnNewSamples = void OnNewSamples(int32 newTicks)
	OnFinishSamplingBlock = void OnFinishSamplingBlock()
	OnFinishSampling = void OnFinishSampling()
	OnSelectionChange = void OnSelectionChange()
	OnCommentAdded = void OnCommentAdded(string text, int32 channel, int32 recordIndex, int32 position)
	OnDigitalInputChangedAdvanced = void OnDigitalInputChangedAdvanced(int32 digitalByteOld, int32 digitalByteNew, int32 tick)
	OnGuidelineCrossed = void OnGuidelineCrossed(int32 channelNumber, int32 guidelineNumber, bool isRising, int32 position, double guidelineValue, double signalValue)
	OnKeysPressed = void OnKeysPressed(string key, bool isControlKeyDown, bool isShiftKeyDown)
	OnDataPadSelectionChanged = void OnDataPadSelectionChanged(int32 sheet, int32 column, int32 row, int32 width, int32 height)
	OnEventDataArrived = void OnEventDataArrived(int32 channelNumber, bool isInternalDetectorChannel, double eventValue, int32 position)
    
    %}
    
    
    %registerevent
    
    properties (Hidden)
        h
    end
    
    properties (Dependent)
        on_selection_change
    end
    
    properties (Hidden)
        on_selection_change_main
    end
    
    methods
        %This approach currently only allows one callback
        function value = get.on_selection_change(obj)
            value = obj.on_selection_change_main;
        end
        function set.on_selection_change(obj,value)
            %
            %
            %   - Perhaps we could check for a cell
            %   - Perhaps we could also add methods for adding
            %   additional callbacks to a particular event
            %
            
            TEMP_1 = {'OnSelectionChange' obj.on_selection_change_main};
            TEMP_2 = {'OnSelectionChange' value};
            
            %This isn't working ...
            if ~isempty(obj.on_selection_change_main)
                unregisterevent(obj.h,TEMP_1);
            end
            
            obj.on_selection_change_main = value;
            
            if ~isempty(value)
                registerevent(obj.h,TEMP_2)
            end
            
            
        end
    end
    
    methods
        function obj = doc_events(h)
            obj.h = h;
        end
        function getCommentAddedData(obj,varargin)
            
        end
    end
    
    methods (Hidden)
        function testCallback(varargin)
            keyboard
        end
    end
    
end

