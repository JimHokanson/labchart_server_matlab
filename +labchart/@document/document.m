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
    block_number = 3;
    seconds_per_tick = d.getSecondsPerTick(block_number);
    n_ticks = d.getRecordLengthInTicks(block_number);
    n_seconds = d.getRecordLengthInSeconds(block_number);
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
        function seconds = getSecondsPerTick(obj,block_number_1b)
             %TODO: try/catch with block check
             seconds = obj.h.GetRecordSecsPerTick(block_number_1b-1);
             %GetRecordSecsPerTick(block As Long) As Double
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
