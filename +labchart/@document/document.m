classdef document < handle
    %
    %   Class:
    %   labchart.document
    %
    %   Constructors
    %   ------------
    %   labchart.openDocument()
    %   labchart.getActiveDocument()
    
    %{
    number_of_records
    is_sampling
    block_number = 4;
    seconds_per_tick = d.getSecondsPerTick(block_number);
    n_ticks = d.getRecordLengthInTicks(block_number);
    n_seconds = d.getRecordLengthInSeconds(block_number);
    
    chan_number = 1;
    data = d.getSelectedData(chan_number);
    %}
    
    properties (Hidden)
        h %Interface.ADInstruments_LabChart_1.0_Type_Library.IADIChartDocument
        %
        %   ADInstruments object instance that we make calls against
        app_object %labchart
        event_manager
    end
    
    properties (Dependent)
        selection %Interface.ADInstruments_LabChart_1.0_Type_Library.IADIChartSelection
        %
        %   Requesting the selection, r
    end
    
    methods
        function value = get.selection(obj)
            value = labchart.selection(obj.h.SelectionObject);
        end
        function set.selection(obj,value)
            %TODO: Check if this is the Matlab object or the raw handle
            obj.h.SelectionObject = value;
        end
    end
    
    %Status Properties
    %-----------------------------------------------------
    properties
        d0 = '-------  Status  -------'
    end
    properties (Dependent)
        number_of_records
        current_record
        %-1 if not sampling
        
        is_sampling
        is_record_mode %???
        %TODO: Add more documentation on what this is
        %       "whether in record mode (even if not sampling) rather tha monitor mode"
        %This seems like monitor mode might indicate when it can't connect
        %with the hardware
    end
    methods
        function value = get.number_of_records(obj)
            value = obj.h.NumberOfRecords;
        end
        function value = get.current_record(obj)
            value = obj.h.SamplingRecord;
            %-1 is for not sampling
            %otherwise shift from 0 to 1 based
            if value ~= -1
                value = value + 1;
            end
        end
        function value = get.is_sampling(obj)
            value = obj.h.IsSampling;
        end
        function value = get.is_record_mode(obj)
            value = obj.h.IsRecordMode;
        end
    end
    
    %Channel Based
    %----------------------------------------------------------------------
    properties
        d1 = '-------  Channels --------'
    end
    properties (Dependent)
        number_of_channels
        number_of_displayed_channels
        channel_names
    end
    methods
        function value = get.number_of_channels(obj)
            value = obj.h.NumberOfChannels;
        end
        function value = get.number_of_displayed_channels(obj)
            value = obj.h.NumberOfDisplayedChannels;
        end
        function value = get.channel_names(obj)
            n_chans = obj.number_of_channels;
            value = cell(1,n_chans);
            local_h = obj.h;
            for iChan = 1:n_chans
                value{iChan} = local_h.GetChannelName(iChan);
            end
        end
    end
    
    %File Information
    %----------------------------------------------------------------------
    properties
        d2 = '-------- File Information -------'
    end
    properties (Dependent)
        name
        file_path
        root_path
        %saved - true if document hasn't changed since last being saved
    end
    
    methods
        function value = get.name(obj)
            value = obj.h.Name;
        end
        function value = get.file_path(obj)
            value = obj.h.FullName;
        end
        function value = get.root_path(obj)
            value = obj.h.Path;
        end
    end
    
    properties
        d3 = '--------- Method Containers -------'
        view
        stimulator
    end
    
    methods
        function record_obj = getRecord(obj,record_id)
            %TODO: Do a check on validity of id
            record_obj = labchart.record(obj.h,record_id);
        end
    end
    
    methods
        function obj = document(h,app_object)
            obj.h = h;
            obj.app_object = app_object;
            obj.event_manager = labchart.document.doc_events(h);
            %obj.selection = labchart.document.selection(h.SelectionObject,obj);
            obj.view = labchart.document.view(h);
            obj.stimulator = labchart.document.stimulator(h);
        end
        function n_ticks = getRecordLengthInTicks(obj,block_number_1b)
             n_ticks = obj.h.GetRecordLength(block_number_1b-1);
        end
        function n_seconds = getRecordLengthInSeconds(obj,block_number_1b)
                seconds_per_tick = obj.getSecondsPerTick(block_number_1b);
                n_ticks = obj.getRecordLengthInTicks(block_number_1b);
                n_seconds = n_ticks*seconds_per_tick;
        end
        function ticks_per_sec = getTicksPerSecond(obj,block_number_1b)
            ticks_per_sec = 1./obj.getSecondsPerTick(block_number_1b);
        end
        function seconds = getSecondsPerTick(obj,block_number_1b)
             %TODO: try/catch with block check
             seconds = obj.h.GetRecordSecsPerTick(block_number_1b-1);
             %GetRecordSecsPerTick(block As Long) As Double
        end
        function data = getSelectedData(obj,channel_number_1b_or_char)
            %
            %   WORK IN PROGRESS - Greg should finish
            %
            %   data = d.getSelectedData(channel_number_1b)
            %
            %   Outputs
            %   -------
            %   data : 
            %       Returned as ticks, not at the sampling rate ...
            %
            %   Examples
            %   --------
            %   data = d.getSelectedData(1);
            %
            %   data = d.getSelectedData('Bladder Pressure');
            %
            %   TODO: Support returning a time vector or a data class
            %   time -> nargout == 2
            %   data -> default if sci.time_series.data is present ...
            
            if isnumeric(channel_number_1b_or_char)
                channel_number_1b = channel_number_1b_or_char;
            elseif ischar(channel_number_1b_or_char)
                channel_number_1b = find(strcmp(channel_number_1b_or_char,obj.channel_names));
                %TODO: Make this a helper function
                %
                %TODO: Support partial matching ...
                %mask_or_indices = sl.str.findMatches('pres',{'Bladder Pressure','EUS EMG'},'partial_match',true);
                %mask_or_indices = sl.str.findMatches('pres',{'Bladder ressure','EUS EMG'},'partial_match',true,'n_rule',1);
                if isempty(channel_number_1b)
                    error('unable to find  channel match for: %s',channel_number_1b_or_char);
                elseif length(channel_number_1b) > 1
                    error('multiple channel matches ...')
                end
            else
               error('Unrecognized input for channel number') 
            end
            %-1 returns all selected channels
            %
            %why isn't this an index into the selected channels????
            
            %Tested by manually selecting data and calling
            as_double = 1;
            %This function uses 1 basd channel indexing, not zero!
            data = obj.h.GetSelectedData(as_double,channel_number_1b);
            %data = d.h.GetSelectedData(1,2);
            %GetSelectedData(flags As ChannelDataFlags, [channelNumber As Long = -1])
        end
        function data = getChannelData(obj,channel_number_1b_or_name,block_number_1b,start_sample,n_samples)
            %
            %   WORK IN PROGRESS - Greg should finish
            %   Gets the data from the following:
            %   channel number or name, block number, start sample,
            %   n_samples from start sample
            %
            %   TODO: Use to samples but show an example of going from
            %   time to samples
            %
            %   Example
            %   -------
            %   %Grab 2 seconds starting at 230 seconds from block 5
            %   block_number = 5;
            %   chan_number = 1;
            %   tps = d.getTicksPerSecond(block_number); %tps - ticks per second
            %   data = d.getChannelData(chan_number,block_number,230*tps,2*tps)
            %
            %   Improvements
            %   See getSelectedData
            
            if isnumeric(channel_number_1b_or_name)
                channel_number_1b = channel_number_1b_or_name;
            elseif ischar(channel_number_1b_or_name)
                channel_number_1b = find(strcmp(channel_number_1b_or_name,obj.channel_names));
                %TODO: Make this a helper function
                %
                %TODO: Support partial matching ...
                %mask_or_indices = sl.str.findMatches('pres',{'Bladder Pressure','EUS EMG'},'partial_match',true);
                %mask_or_indices = sl.str.findMatches('pres',{'Bladder ressure','EUS EMG'},'partial_match',true,'n_rule',1);
                if isempty(channel_number_1b)
                    error('unable to find  channel match for: %s',channel_number_1b_or_name);
                elseif length(channel_number_1b) > 1
                    error('multiple channel matches ...')
                end
            else
               error('Unrecognized input for channel number') 
            end

            
            as_double = 1;
            channel_1b = channel_number_1b;
            
            % START SAMPLE IS 1 REFERENCED!
            % but is this going to be off by 1 in some cases?
            data = obj.h.GetChannelData(as_double,channel_1b,block_number_1b,start_sample + 1,n_samples);
            
            %error('Not yet implemented')
            
            %inputs
            %channel - 1 based
            %block number
            
            %data = d.h.GetChannelData(1,1,5,230*20000,2*20000)
            
            %This is too awkward ...
%             in.start_as_samples = [];
%             in.duration_as_samples = [];
%             in.start_as_time = [];
%             in.duration_as_time = [];
%             in = labchart.sl.in.processVarargin(in.varargin);
            
            %GetChannelData(flags As ChannelDataFlags, channelNumber As Long, blockNumber As Long, startSample As Long, numSamples As Long)
        end 
        function addComment(obj,str,channel)
            %
            %   addComment(obj,str, *channel)
            %
            %   Inputs
            %   -------
            %   channel : (default -1)
            %       -1 applies the comment to all channels
            %   	#s are 1 based
            %
            %   Examples
            %   --------
            %   active = labchart.getActiveDocument();
            %   active.addComment('Adding comment to channel 1',1);
            
            if ~exist('channel','var') || isempty(channel)
                channel = -1;
            end
            
            %Transition from 1 based here to 0 based in the code
            if channel ~= -1
                channel = channel - 1;
            end
            
            obj.h.AppendComment(str,channel)
        end
        function addCommentAtSelection(obj,str,channel)
            %
            %   For wide selections the comment is added halfway through
            %   the document ?? - not halfway at the selection?
            %   I guess it is unclear what this means when crossing
            %   blocks with differnt sampling rates - halfway by ticks?
            
            if ~exist('channel','var') || isempty(channel)
                channel = -1;
            end
            
            %Transition from 1 based here to 0 based in the code
            if channel ~= -1
                channel = channel - 1;
            end
            
            obj.h.AddCommentAtSelection(str,channel)
        end
        function selectChannel(obj,channel_1b__or_name)
            %
            %   d.selectChannel(channel_1b__or_name)
            
            obj.h.SelectChannel(channel_1b__or_name-1,true);
            %SelectChannel(channel As Long, select As Boolean)
        end
        function setSelectionTime(obj)
            %SetSelectionTime
            obj.h.SetSelectionTime(start_block,start_offset,end_block,end_offset)
            %d.h.SetSelectionTime(4,10,4,20)
            %SetSelectionTime(startBlock As Long, startOffsetInSecs As Double, endBlock As Long, endOffsetInSecs As Double)
        end
        function startSampling(obj,varargin)
            %
            %   startSampling(obj)
            %
            %   Examples
            %   --------
            %   %Start sampling for an indefinite period and return
            %   %immediately
            %   active = labchart.getActiveDocument();
            %   active.startSampling();
            
            %Status: Haven't tested all values of inputs
            
            
            in.time = 0; %0 means sample indefinitely
            in.block_until_done = false;
            in.sample_stop_mode = 0;
            in = labchart.sl.in.processVarargin(in,varargin);
            %0 - period
            %1 - stop sampling after trigger
            %2 - user stop
            %time in seconds
            %wait for sampling
            
            obj.h.StartSampling(in.time,in.block_until_done,in.sample_stop_mode);
        end
        
        function stopSampling(obj)
            obj.h.StopSampling();
        end
        function save(obj)
            obj.h.Save();
        end
        
    end
end


%{
Views
-----
'Chart View'
'Plot View'
GetViewPos - 4x1 cell

Macros
------
Macros() - returns IADIChartScripts which doesn't seem to do anything
PlayMacro(macro_name)
- looks like it may be blocking
- returns boolean of success or failure
ImportMacros(file_path)


%}

%{

%{
'Application'
'Parent'
DONE 'Name' => name
DONE 'FullName' => file_path
DONE 'Path' => root_path
'Saved'
DONE 'NumberOfRecords'
DONE 'NumberOfChannels'
'SelectionStartRecord'
'SelectionStartOffset'
'SelectionEndRecord'
'SelectionEndOffset'
'SelectionObject'
NYI 'Macros'
NYI 'Services'
DONE 'IsSampling' => is_sampling
DONE 'IsRecordMode' => is_record_mode
DONE 'SamplingRecord' => current_record
DONE 'NumberOfDisplayedChannels'
    
%}
    

%==== Methods =====

Activate
AddCommentAtSelection
AddToDataPad
AppendComment
AppendFile
AppendFileEx
Close
CreatePlot
GetChannelData
GetChannelName
GetDataPadColumnChannel
GetDataPadColumnFuncName
GetDataPadColumnUnit
GetDataPadCurrentValue
GetDataPadValue
GetDigitalInputBit
GetDigitalInputState
GetDigitalOutputBit
GetDigitalOutputState
GetName
GetPlot
GetPlotId
GetRecordLength
GetRecordSecsPerTick
GetRecordStartDate
GetScopeChannelData
GetSelectedData
GetSelectedValue
GetUnits
GetViewPos
ImportMacros
IsChannelSelected
MatLabPutChannelData
MatLabPutFullMatrix
PlayMacro
PlayMessage   %hexadecimal message string => checksum failed
Print
RecordTimeToTickPosition
ResetSelection
Save
SaveAs
SaveChartViewAsImage
SelectChannel
SelectRecord
SetAnalogOutputValue
SetArithChanCalc
SetChannelName
SetDevice
SetDigitalOutputBit
SetDigitalOutputState
SetSelectionRange
SetSelectionTime
DONE StartSampling
StopSampling
TickPositionToRecordTime
WaitWhileSampling
addproperty
delete
deleteproperty
events
get
invoke
loadobj
release
saveobj
set

%}
