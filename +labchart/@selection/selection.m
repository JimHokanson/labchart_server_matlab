classdef selection
    %
    %   Class:
    %   labchart.selection
    %
    %   Wraps:
    %   ADIChart.Selection
    
    %{
    Might create a flag indicating whether or not the selection is linked
    ...
    %TODO: This seems necessary, as even getting it from the document
    %and updating it isn't sufficient to cause the document to use the
    selection
    
    The problem is that the selection is ill defined until
    it is fully specified. The updates should probably be a method then
    like makeSelection
    - selectPoint
    - selectSpan
    
    Creation Methods:
    1) s = actxserver('ADIChart.Selection')
    2) doc.SelectionObject
    
    %}
    
    
    properties
        
    end
    
    properties (Hidden)
       h
       doc  %labchart.document
    end
    
    properties (Dependent)
       start_record
       start_offset
       end_record
       end_offset
%        chan_range_bottom
%        chan_range_top
    end
    
    methods
        function value = get.start_record(obj)
           value = obj.h.SelectionStartRecord + 1; 
        end
        function value = get.start_offset(obj)
           value = obj.h.SelectionStartOffset; 
        end
        function value = get.end_record(obj)
           value = obj.h.SelectionEndRecord + 1; 
        end
       	function value = get.end_offset(obj)
           value = obj.h.SelectionEndOffset;
        end
%         function value = get.chan_range_bottom(obj)
%            
%         end
%         function value = get.chan_range_top(obj)
%             value = obj.h.GetChannelRangeTop; 
%         end
    end
    
    methods
        function obj = selection(h,doc)
           obj.h = h; 
           obj.doc = doc;
        end
        function selected = isChannelSelected(obj,chan_index_1b)
            %
            %   TODO: document function 
            %
            %   
            
            %They 0 use based indexing for this function
            selected = obj.h.IsChannelSelected(chan_index_1b-1);
        end
        function set_channel_range(obj)
            error('Not yet implemented')
            %This is going to require a bit of work as we might
            %want to work with the channel names directly, or a 1 based
            %channel index, the y-ranges should also probably be in units
            %and not from -1 to 1 (although this would be allowable too
            %with an option
        end
        function getMinValueOfSelectedChan(chan_index_1b)
            %value = obj.h.GetChannelRangeBottom(chan_index_1b-1); 
        end
        function getMaxValueOfSelectedChan(chan_index_1b)
            %value = obj.h.GetChannelRangeBottom(chan_index_1b-1); 
        end
    end
    
end

%{

    'GetChannelRangeBottom'
    'GetChannelRangeTop'
    'IsChannelSelected'
    'ResetSelection'
    'SelectChannel'
    'SetChannelRange'
        0_based_chan_id, 

    'SetSelectionRange'
        start_block, block_offset, end_block, end_offset

    'addproperty'
    'delete'
    'deleteproperty'
    'events'
    'get'
    'invoke'
    'loadobj'
    'release'
    'saveobj'
    'set'

%}