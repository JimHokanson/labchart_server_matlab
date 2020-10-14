classdef document < handle
    %
    %   Class:
    %   labchart.document
    %
    %   Constructors
    %   ------------
    %   labchart.openDocument()
    %   labchart.getActiveDocument()
    
    %File naming notes
    %-----------------
    %- New documents are named Document#, which increments with
    %   opening each new document
    
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
            value = labchart.selection(obj.h.SelectionObject,obj);
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
        %Saw value of 1 while opening a file not connected to Labchart
        %
        %TODO: Add more documentation on what this is
        %       "whether in record mode (even if not sampling) rather tha monitor mode"
        %This seems like monitor mode might indicate when it can't connect
        %with the hardware
        
        event_listeners
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
        function value = get.event_listeners(obj)
            value = obj.h.eventlisteners;
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
        units
    end
    
    %Dependent methods
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
        function value = get.units(obj)
            n_chans = obj.number_of_channels;
            last_record = obj.number_of_records;
            value = cell(1,n_chans);
            local_h = obj.h;
            for iChan = 1:n_chans
                value{iChan} = local_h.GetUnits(iChan,last_record);
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
    
    %Dependent methods
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
        comments
    end
    
    %Dependent methods
    methods
        function record_obj = getRecord(obj,record_id)
            %TODO: Do a check on validity of id
            record_obj = labchart.record(obj.h,record_id);
        end
    end
    
    %MAIN METHODS
    %----------------------------------------------------------------------
    methods
        function obj = document(h,app_object)
            obj.h = h;
            obj.app_object = app_object;
            obj.event_manager = labchart.document.doc_events(h);
            %obj.selection = labchart.document.selection(h.SelectionObject,obj);
            obj.view = labchart.document.view(h);
            obj.comments = labchart.document.comments(h);
            
            obj.stimulator = labchart.stim(obj);
            %obj.stimulator = labchart.document.stimulator(h);
        end
        function delete(obj)
            %disp('Disconnecting document from Labchart')
            if ~isempty(obj.event_listeners)
                obj.unregisterAllEvents();
            end
            obj.h.release()
        end
        function stopEvents(obj)
           obj.unregisterAllEvents();
        end
        function unregisterAllEvents(obj)
            if ~isempty(obj.event_listeners)
                obj.h.unregisterallevents();
            end
        end
        function registerSelectionChangeCallback(obj,callback_fh)
            obj.h.registerevent({'OnSelectionChange',callback_fh})
        end
        function registerOnNewSamplesCallback(obj,callback_fh)
            %
            %   Callback returns 5 inputs:
            %   ---------------------------
            %   1) Interface : it looks like this is a pointer to the
            %   record that just stopped? Methods calls fail ...
            %   2) EventID : 3
            %   3) struct, containing fields:
            %       - 'Type' - 'OnNewSamples'
            %       - 'Source' [1×1 Interface.9A74BBA2_5C34_4231_9275_3E7E24A042B8]
            %       - 'EventID' - 3
            %       - newTicks: 1000
            %   4) Type : 'OnStartSamplingBlock'
            %
            %   See Also
            %   --------
            %   labchart.callbacks
            
            obj.h.registerevent({'OnNewSamples',callback_fh})
        end
        function registerBlockStartCallback(obj,callback_fh)
            %
            %   Note, execution of this callback blocks Labchart
            %   visualization (data collection still happening)
            %
            %   Callback returns 4 inputs:
            %   ---------------------------
            %   1) Interface : it looks like this is a pointer to the
            %   record that just stopped? Methods calls fail ...
            %   2) EventID :
            %   3) struct, containing fields:
            %       - 'Type' - 'OnStartSamplingBlock'
            %       - 'Source' [1×1 Interface.9A74BBA2_5C34_4231_9275_3E7E24A042B8]
            %       - 'EventID' - 2
            %       -
            %   4) Type : 'OnStartSamplingBlock'
            %
            %   See Also
            %   --------
            %   labchart.callbacks
            
            obj.h.registerevent({'OnStartSamplingBlock',callback_fh})
        end
        function registerBlockEndCallback(obj,callback_fh)
            %
            %   Callback returns 4 inputs:
            %   ---------------------------
            %   1) Interface : it looks like this is a pointer to the
            %   record that just stopped? Methods calls fail ...
            %   2) EventID :
            %   3) struct, containing fields:
            %       - 'Type' - 'OnFinishSamplingBlock'
            %       - 'Source' [1×1 Interface.9A74BBA2_5C34_4231_9275_3E7E24A042B8]
            %       - 'EventID' - 4
            %       -
            %   4) Type : 'OnFinishSamplingBlock'
            %
            %   See Also
            %   --------
            %   labchart.callbacks
            
            obj.h.registerevent({'OnFinishSamplingBlock',callback_fh})
        end
        function close(obj)
            %You can optionally force closing of an unsaved document with
            %an optional true (NOT IMPLEMENTED) - might name as
            %forceClose()
            obj.h.Close() 
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
        function sampling_rate = getRecordGlobalSamplingRate(obj,block_number_1b)
            seconds = getSecondsPerTick(obj,block_number_1b);
            sampling_rate = 1/seconds;
        end
        function seconds = getSecondsPerTick(obj,block_number_1b)
            %TODO: try/catch with block check
            seconds = obj.h.GetRecordSecsPerTick(block_number_1b-1);
            %GetRecordSecsPerTick(block As Long) As Double
        end
        function data = getSelectedData(obj,channel_number_1b_or_char,varargin)
            %x Returns selected data
            %
            %   data = d.getSelectedData(channel_number_1b,varargin)
            %
            %   data = d.getSelectedData(channel_name,varargin)
            %
            %   Inputs
            %   ------
            %   channel_number_1b : number
            %       Which channel to grab data from. This is not an index
            %       into the selection but rather an index into all
            %       available channels.
            %
            %       A value of -1 indicates that all selected channels will
            %       be returned.
            %
            %   channel_name : char
            %
            %   Outputs
            %   -------
            %   data : raw data or sci.time_series.data if present
            %       Returned as ticks, not at the sampling rate.
            %
            %   Optional Inputs
            %   ---------------
            %   return_object : (default true)
            %       This only works if Jim's standdard library is installed
            %   n_decimate : (default 1)
            %       Not yet implemented. Currently everything is returned
            %       at a tick rate instead of its real sampling rate.
            %
            %   Examples
            %   --------
            %   data = d.getSelectedData(1);
            %
            %   data = d.getSelectedData('Bladder Pressure');
            %
            %   Improvements
            %   ------------
            %   1)
            %
            %   Questions
            %   ---------
            %   1) What happens across block boundaries?
            %       Data gets merged. Eventually we might be able to split
            %       this ...
            %
            %   TODO: Support returning a time vector or a data class
            %   time -> nargout == 2
            %   data -> default if sci.time_series.data is present ...
            
            %TODO: Check selection to verify we aren't spanning records
            
            in.return_object = true;
            in.n_decimate = 1;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            if isnumeric(channel_number_1b_or_char)
                channel_number_1b = channel_number_1b_or_char;
            elseif ischar(channel_number_1b_or_char)
                channel_number_1b = h__chanNameToIndex(obj,channel_number_1b_or_char);
            else
                error('Unrecognized input for channel number')
            end
            
            as_double = 1;
            
            %This function uses 1 based channel indexing, not zero!
            data = obj.h.GetSelectedData(as_double,channel_number_1b);
            
            if in.return_object && exist('sci.time_series.data') %#ok<EXIST>
                %Yikes, in order to get this to work we need to know what
                %the selection is (specifically which block)
                
                start_record = obj.selection.start_record;
                ticks_per_sec = obj.getTicksPerSecond(start_record);
                sample_offset = obj.selection.start_offset;
                
                dt = 1/ticks_per_sec;
                
                n_samples = length(data);
                time_object = sci.time_series.time(dt,n_samples,'sample_offset',sample_offset);
                data = sci.time_series.data(data(:),time_object);
                
            elseif nargout == 2
                %return a time vector ...
                error('Not yet implemented')
            end
        end
        function flag = hasData(obj,channel_number_1b_or_name,block_number_1b)
            %
            %   flag = hasData(obj,channel_name,block_number)
            %
            %   flag = hasData(obj,channel_number,block_number)
            %
            %   Returns whether the channel has samples. Note, I know of 
            %   no way doing this the "right" way so we try to request a 
            %   single sample of data. Labchart returns NaN when invalid 
            %   data requests are made (as long as the channel and block
            %   exist).
            %
            %   Inputs
            %   ------
            %   channel_name : string
            %       Name of the channel.
            %   channel_number : 1 based
            %   block_number : 1 based
            %
            %   Possible Errors
            %   ---------------
            %   - channel index doesn't exist
            %   - block number doesn't exist
            %
            %   Note, the channel not having any data is not an error
            %
            %   Outputs
            %   -------
            %   flag : logical
            %       Whether any data has been collected for that channel
            %       for that record.
            %    
            %
            %   Example
            %   -------
            %   %Did stim2 record any data for block 1?
            %   chan_index = 5;
            %   block_number = 1;
            %   flag = doc.hasData(chan_index,block_number);
            %
            %   %Alternatively ...
            %   flag = doc.hasData('stim2',block_number);
            
            missing_ok = true;
            I = h__chanNameToIndex(obj,channel_number_1b_or_name,missing_ok);
            if isempty(I)
                flag = false;
            else
                temp_data = obj.getChannelData(channel_number_1b_or_name,...
                    block_number_1b,1,1,'return_obj',false);
                flag = ~isnan(temp_data);
            end
            
        end
        function [data,time] = getChannelData(obj,...
                    channel_number_1b_or_name, ...
                    block_number_1b,...
                    start_sample, n_samples, varargin)
            %x Returns data from a given channel
            %
            %   [data,time] = d.getChannelData(channel_number_1b, block_number, start_sample, n_samples, varargin)
            %
            %   Channel Name instead of number
            %   ... = d.getChannelData(channel_name, block_number, start_sample, n_samples, varargin)
            %
            %   Inputs specified as time
            %   ... = d.getChannelData(channel_name, block_number, start_time, duration, 'as_time', true)
            %
            %   Usage Quirks
            %   ------------
            %   1) Data from all channels are returned at the
            %   highest sampling rate. Channels that are sampled at
            %   lower rates will have repeat values (sample and hold).
            %   2) Requesting data that doesn't exist does not throw
            %   an error. The only restriction is that the sample # must
            %   be greater than 1. Non-existant data are returned as NaN
            %
            %   Inputs
            %   ------
            %   channel_number_1b_or_name : number or string
            %       The channel number or its name in the list of channels
            %   block_number : scalar
            %       The number of the block as it shows up on the display
            %       in LabChart
            %   start_sample : scalar
            %       The start sample within the chosen block. The first
            %       sample is 1.
            %   n_samples : scalar
            %       number of samples to go from start_sample. Apparently
            %       -1 gives you everything ...
            %   start_time : scalar
            %       Time starts from 0
            %   duration :
            %       Duration in seconds to return
            %
            %   Optional Inputs
            %   ---------------
            %   return_obj : default true
            %        - true, returns a sci.time_series.data class
            %                This relies on having Jim's Matlab Standard
            %                library on the path
            %        - false, returns a vector of points
            %   as_time : default false
            %
            %
            %   Output
            %   ------
            %   data : sci.time_series.data or numeric array
            %       Note sci.time_series.data requires an additional
            %       library.
            %
            %   Example
            %   -------
            %   %Grab 2 seconds starting at 230 seconds from block 5
            %   block_number = 5;
            %   chan_number = 1;
            %   tps = d.getTicksPerSecond(block_number); %tps - ticks per second
            %   data = d.getChannelData(chan_number,block_number,230*tps,2*tps)
            %
            %   data = d.getChannelData(chan_number,block_number,0,230,'as_time',true)
            %
            %   Improvements
            %   See getSelectedData
            
            in.as_time = false;
            in.return_obj = true;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            % processing for different input types on channel selection:
            if isnumeric(channel_number_1b_or_name)
                channel_number_1b = channel_number_1b_or_name;
            elseif ischar(channel_number_1b_or_name)
                channel_number_1b = h__chanNameToIndex(obj,channel_number_1b_or_name);
            else
                error('Unrecognized input for channel number')
            end
            
            if in.as_time
                tps = obj.getTicksPerSecond(block_number_1b); %tps - ticks per second
                start_time = start_sample;
                start_sample = round(start_time*tps)+1;
                duration = n_samples;
                n_samples = round(duration*tps);
            end
            
            %The other option is an array of variants ...
            %Not sure what that is ...
            AS_DOUBLE = 1;
            
            data_vector = obj.h.GetChannelData(...
                AS_DOUBLE,...
                channel_number_1b,...
                block_number_1b,...
                start_sample,...
                n_samples);
            
            if in.return_obj && ~isempty(which('sci.time_series.data'))
                %This is incorrect as it grabs the last block and that
                %may be incorrect (if channel is off units become '')
                %or they may change between blocks with the bioamp => mV vs
                %uV
                %units = obj.units{channel_number_1b};
                local_units = obj.h.GetUnits(channel_number_1b,block_number_1b);
                %Note, this requires Jims Matlab Standard Library
                %   https://github.com/JimHokanson/matlab_standard_library
                tps = obj.getTicksPerSecond(block_number_1b);
                dt = 1/tps;
                data = sci.time_series.data(data_vector',dt,...
                    'y_label',obj.channel_names{channel_number_1b},...
                    'units',local_units);
            else
                data = data_vector;
            end
            
            if nargout == 2
                tps = obj.getTicksPerSecond(block_number_1b);
                time = 0:(length(data_vector)-1);
                time = time.*(1/tps);
            else
                time = [];
            end
        end
        function addComment(obj,str,channel)
            %
            %   addComment(obj,str,*channel)
            %
            %   Inputs
            %   ------
            %   channel : (default -1)
            %       -1 applies the comment to all channels
            %   	#s are 1 based
            %
            %   Examples
            %   --------
            %   active = labchart.getActiveDocument();
            %   active.addComment('Adding comment to channel 1',1);
            
            %   TODO: Push this code into comments
            %
            %   Note: my current Labchart version only shows:
            %   - AddCommentAtEnd
            %   - AddCommentAtInsertionPoint
            %   - AddCommentAtPositionEx
            
            if ~exist('channel','var') || isempty(channel)
                channel = -1;
            end
            
            %Transition from 1 based here to 0 based in the code
            if channel ~= -1
                channel = channel - 1;
            end
            
            %Added this in when I lost 10 minutes on a cellstr input
            if ~isnumeric(channel) || ~ischar(str)
                error('Incorrect input types')
            end
            
            %???? How does this compare to AddCommentAtEnd
            obj.h.AppendComment(str,channel)
        end
        function addCommentAtSelection(obj,str,channel)
            %
            %   addCommentAtSelection(obj,str,*channel)
            %
            %   For wide selections the comment is added halfway through
            %   the document ?? - not halfway at the selection?
            %   I guess it is unclear what this means when crossing
            %   blocks with differnt sampling rates - halfway by ticks?
            %
            %   Inputs
            %   ------
            %   str : string
            %       Comment to add
            %   channel : scalar, 1 based, default -1
            %       Channel # to add the comment to. -1 indicates the
            %       comment should be added to all channels.
            
            if ~exist('channel','var') || isempty(channel)
                channel = -1;
            end
            
            %Transition from 1 based here to 0 based in the code
            if channel ~= -1
                channel = channel - 1;
            end
            
            obj.h.AddCommentAtSelection(str,channel)
        end
        %Not needed
%         function getNonEmptyUnits(obj,channel_1b,record_1b)
%             
%             local_h = obj.h;
%             
%             units = local_h.GetUnits(channel_1b,record_1b);
%             if isempty(units)
%                 %Scan left
%                 record_1b = record_1b - 1;
%                 while (record_1b > 0)
%                    units = local_h.GetUnits(channel_1b,record_1b);
%                    if ~isempty(units)
%                        
%                    end
%                 end
%             end
%         end
        function units = getAllChannelUnits(obj,channel_1b)
            units = cell(1,obj.number_of_records);
            for i = 1:obj.number_of_records
               units{i} = obj.h.GetUnits(channel_1b,i); 
            end
        end
        
        function selectChannel(obj,channel_1b__or_name)
            %
            %   d.selectChannel(channel_1b__or_name)
            
            obj.h.SelectChannel(channel_1b__or_name-1,true);
            %SelectChannel(channel As Long, select As Boolean)
        end
        function setSelectionTime(obj)
            error('Not yet implemented')
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
        function saveAs(obj,file_path)
            %TODO: If no file_path, do a prompt, not sure if it makes sense
            %to try and punt the ui interface and saving in Labchart,
            %rather than doing a uiputfile in Matlab.
            obj.h.SaveAs(file_path);
        end
    end
end


%         doc.unregisterallevents
%     end
%     doc.release

function I = h__chanNameToIndex(obj,name,missing_ok)

%Hack to avoid checking ...., should be cleaned up ...
if isnumeric(name)
   I = name; 
end

if nargin < 3
    missing_ok = false;
end

if isempty(obj.channel_names)
    if missing_ok
        I = [];
    else
        error('No channels available, this happens when data collection has not yet started')
    end
else
    if missing_ok
        n_rule = 0; %0 or 1
    else
        n_rule = 1; %only 1
    end
    I = labchart.sl.str.findMatches(name,obj.channel_names,...
        'partial_match',true,'n_rule',n_rule,'multi_result_rule','exact_or_error');
end

% % % channel_number_1b = find(strcmp(channel_number_1b_or_char,obj.channel_names));
% % % %TODO: Make this a helper function
% % % %
% % % %TODO: Support partial matching ...
% % % %mask_or_indices = sl.str.findMatches('pres',{'Bladder Pressure','EUS EMG'},'partial_match',true);
% % % %mask_or_indices = sl.str.findMatches('pres',{'Bladder ressure','EUS EMG'},'partial_match',true,'n_rule',1);
% % % if isempty(channel_number_1b)
% % %     error('unable to find  channel match for: %s',channel_number_1b_or_char);
% % % elseif length(channel_number_1b) > 1
% % %     error('multiple channel matches ...')
% % % end

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

% Record data
% %off
% invoke(d.h,'PlayMessage','0x0400000001000000FFFFFFFF01000000FFFFFFFFFD1A0000AAAA1455010000000400FF7F904BA734BC0DD311B870008048C36FE8000000003200FF7F4002D1870D0FD311B871008048C36FE8000000000000000008000000')
% %on
% invoke(d.h,'PlayMessage','0x0400000001000000FFFFFFFF01000000FFFFFFFFFE1A0000AAAA1455010000000400FF7F904BA734BC0DD311B870008048C36FE8000000003200FF7F4002D1870D0FD311B871008048C36FE8000000000100000008000000')
