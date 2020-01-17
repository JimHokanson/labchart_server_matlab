classdef streamed_data1 < handle
    %
    %   Class:
    %   labchart.streaming.streamed_data1
    %
    %   Holds on to a limited set of previously seen streamed data. Once
    %   too much data has been received old data points get dumped.
    %   Internally a buffer is used so that "dumping" only occurs
    %   ocassionally.
    %
    %   Name note, regarding #1, this was with the thought that we might
    %   eventually have multiple implementations and that this was the
    %   first one created.
    %
    %   Buffer Algorithm
    %   ----------------
    %
    %   
    %          |------------------------------------| <= buffer
    %                     . <= pointer to last valid index
    %   Time 1: xxxxxxxxxxx   <= data points
    %     ...                               (345 data as well)
    %                                         .
    %   Time J: xxxxxxxxxxxxxxxxxxxxxxxxxxxx345 + yyyyyyyyy <= overflow                               
    %   
    %   When we have overflow, we shift what we want to have
    %   available 'n_seconds_keep_valid' from the end to the beginning
    %
    %                      . 
    %   Time J: x345yyyyyyyyyxxxxxxxxxxxxxxx345yyyyy 
    %
    %   Thus valid data grabs always go from the pointer '.' backwards
    %                                   
    %   Benefits
    %   --------
    %   - Efficiently logs data (no concatenation)
    %   - Only holds on to a set amount of data (memory usage shouldn't
    %   be a concern)
    %   - Supports removal of sample & held data that Labchart returns
    %     to the user
    %   - Supports stream plotting
    %
    %   Improvements
    %   ------------
    %   1) Support downsampling further ...
    
    properties
        data
        
        d0 = '-- properties --'
        fs %sampling rate
        chan_index
        data_dt
        
        d1 = '-- required parameters --'
        n_seconds_keep_valid %# of seconds that must be valid
        %at all times
        chan_index_or_name %Which channel to work with. This can be either
        %a 1 based index or the name of the channel (case-insensitive)
        
        
        d2 = '-- optional parameters --'
        %See documentation in the constructor for these ...
        axis_width_seconds
        auto_detect_record_change
        buffer_muliplier %How big to make the buffer relative to the amount
        %of data we want to ensure is always valid ...
        h_axes %Handle to an axes object for plotting into
        plot_options
        new_data_processor
        remove_sample_hold 
        
        d3 = '-----   state   -----'
        block_initialized = false %
        %Block initialized values
        %--------------------------------------------------
        decimation_step_size %This is particular to removing sample & hold
        %- step size in # of samples to keep, i.e. if we are sampling
        %at 1000Hz but the global rate is 20000Hz, we need to keep every
        %20th sample
        ticks_per_second
        current_record = 0
        error_thrown = false %On error in the callback we toggle this
        %so that we don't have a ton of errors getting thrown
        h_line
        
        
        d4 = '----- buffer state ------'
        n_samples_keep_valid
        last_valid_I = 0
        n_seconds_valid %This might be useful for the user
        %as it can be queried ...
        buffer_size
        last_grab_start %tick of last grab start
        last_grab_end %tick of last grab end
        %   Note, this must be updated if we just grab everything ...
        
        
        d5 = '---- performance ----'
        n_add_data_calls = 0
        add_data_times = zeros(1,100)
        add_data_times_I = 0
        callback_times = zeros(1,100)
        callback_times_I = 0
        h_tic_start
    end
    
    methods
        function obj = streamed_data1(fs,n_seconds_keep_valid,chan_index_or_name,varargin)
            %
            %   obj = labchart.streaming.streamed_data1(fs, ...
            %           n_seconds_keep_valid,chan_index_or_name,varargin)
            %
            %
            %   TODO: Update this documentation
            %
            %   Inputs
            %   ------
            %   fs : scalar
            %       Sampling rate of this channel
            %   n_seconds_keep_valid : scalar
            %       minimum # of seconds that should be available via
            %       getData()
            %
            %
            %   Optional Inputs
            %   ---------------
            %   auto_detect_record_change
            %
            %   remove_sample_hold : (default true)
            %       If true, replication due to sample & hold is removed. 
            %       All channels except the highest rate channel will
            %       return data at the high rate with values sampled and
            %       held at the specified channel sampling rate. For
            %       example if we sample at 10Hz but our highest rate is
            %       100 Hz by default we'll get 100Hz data with changes
            %       every 10th sample
            %
            %   Example
            %   -------
            %   d = labchart.getActiveDocument();
            %   name = 'void volume low pass ';
            %   fs = 1000;
            %   n_seconds_valid = 10;
            %   s1 = labchart.streaming.streamed_data1(fs,n_seconds_valid,name,...
            %       'h_axes',gca,'plot_options',{'Color','r'});
            %   fh = @(~,~,~,~,~)labchart.callbacks.newDataStreamingExample1(d,s1);
            %   d.registerOnNewSamplesCallback(fh);
            
            in.auto_detect_record_change = true;
            in.axis_width_seconds = [];
            in.buffer_muliplier = 10;
            in.h_axes = [];
            in.new_data_processor = [];
            in.plot_options = {};
            in.remove_sample_hold = true;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            %Inputs
            %------
            obj.fs = fs;
            obj.n_seconds_keep_valid = n_seconds_keep_valid;
            obj.chan_index_or_name = chan_index_or_name;
            
            %Optional Inputs
            %---------------
            obj.auto_detect_record_change = in.auto_detect_record_change;
            obj.axis_width_seconds = in.axis_width_seconds;
            %This 1.1 is somewhat arbitrary ...
            if in.buffer_muliplier <= 1.1
                in.buffer_multiplier = 1.1;
            end
            obj.buffer_muliplier = in.buffer_muliplier;
            
            obj.h_axes = in.h_axes;
            obj.new_data_processor = in.new_data_processor;
            obj.plot_options = in.plot_options;
            obj.remove_sample_hold = in.remove_sample_hold;
        end
        function addData(obj,h_doc)
            %
            %   Inputs
            %   ------
            %   h_doc : labchart.document
            
            %Note, we wrap everything in a try/catch so that
            %if this is broken it only throws 1 error then
            %stops ...
                        
            try
                if ~obj.error_thrown
                    obj.n_add_data_calls = obj.n_add_data_calls + 1;
                    h_tic = tic;
                    
                    %This makes it easier for the user to use ...
                    if obj.auto_detect_record_change
                        if h_doc.current_record ~= obj.current_record
                            obj.block_initialized = false;
                        end
                    end
                    
                    if ~obj.block_initialized
                        is_init_call = true;
                        obj.block_initialized = true;
                        obj.h_tic_start = tic;
                        obj.current_record = h_doc.current_record;
                        obj.ticks_per_second = 1/h_doc.getSecondsPerTick(obj.current_record);
                        
                        %name resolution
                        %--------------------------------
                        if ischar(obj.chan_index_or_name)
                            I = find(strcmpi(h_doc.channel_names,obj.chan_index_or_name));
                            if isempty(I)
                                error('unable to find specified channel for streaming')
                            end
                            obj.chan_index = I;
                        end
                        
                        %step/hold options
                        %--------------------------------------------------
                        if obj.remove_sample_hold
                            %verify decimation amount
                            temp = obj.ticks_per_second/obj.fs;
                            if temp ~= round(temp)
                                %Basically this means the user specified
                                %fs wrong because
                                error('unable to find valid decimation step size')
                            end
                            obj.decimation_step_size = temp;
                            obj.data_dt = 1/obj.fs;
                        else
                            obj.decimation_step_size = 1;
                            obj.data_dt = 1/obj.ticks_per_second;
                        end
                        
                        %Buffer initialization
                        %--------------------------------------------------
                        obj.n_samples_keep_valid = ceil(obj.n_seconds_keep_valid/obj.data_dt);
                        obj.buffer_size = ceil(obj.n_samples_keep_valid*obj.buffer_muliplier);
                        obj.data = zeros(1,obj.buffer_size);
                        obj.last_valid_I = 0;
                        
                        %Plotting
                        %------------------------------------
                        if isvalid(obj.h_axes)
                            obj.h_line = animatedline(...
                                'MaximumNumPoints',obj.buffer_size,...
                                'Parent',obj.h_axes,...
                                obj.plot_options{:});
                        end
                        
                        %Where are we in time??? - how far back do we go???
                        %------------------------------------------------------
                        n_ticks_current_record = h_doc.getRecordLengthInTicks(obj.current_record);
                        n_samples_available = n_ticks_current_record/obj.decimation_step_size;
                        
                        if n_samples_available > obj.n_samples_keep_valid
                            n_samples_grab = obj.n_samples_keep_valid*obj.decimation_step_size;
                            start_I = n_ticks_current_record-n_samples_grab+1;
                        else
                            n_samples_grab = n_ticks_current_record;
                            start_I = 1;
                        end
                        new_data = h__getData(h_doc,obj,start_I,n_samples_grab);
                    else %already initialized
                        is_init_call = false;
                        new_data = h__getData(h_doc,obj,obj.last_grab_end+1,-1);
                        
                        I2 = obj.callback_times_I;
                        if I2 == 100
                            I2 = 1;
                        else
                            I2 = I2 + 1;
                        end
                        obj.callback_times(I2) = toc(obj.h_tic_start);
                        obj.callback_times_I = I2;
                    end
                    
                    %At this point we are initialized and have 'new_data'
                    %as well as an updated state
                    
                    %Remove held samples ...
                    %-------------------------------------------
                    if obj.decimation_step_size ~= 1
                        new_data = new_data(1:obj.decimation_step_size:end);
                    end
                    
                    %Processing
                    %----------------------------------------------------------
                    %   Example: labchart.streaming.processors.butterworth_filter
                    
                    %NOTE: Due to use of data_dt we can't downsample here
                    %... Eventually we should support this ...
                    if ~isempty(obj.new_data_processor)
                        new_data = obj.new_data_processor(new_data,is_init_call);
                    end
                    
                    %Plotting
                    %----------------------------------------------------------
                    if isvalid(obj.h_line)
                        x1 = obj.last_grab_start/obj.ticks_per_second;
                        x2 = obj.last_grab_end/obj.ticks_per_second;
                        x = x1:obj.data_dt:x2;
                        addpoints(obj.h_line,x,new_data);
                        if ~isempty(obj.axis_width_seconds)
                            set(obj.h_axes,'xlim',[x2-obj.axis_width_seconds x2])
                        end
                    end
                    
                    %Adding data to buffer for analysis
                    %----------------------------------------------------------
                    if length(new_data) > obj.n_samples_keep_valid
                        obj.data = new_data(end-obj.n_samples_keep_valid+1:end);
                        obj.last_valid_I = length(obj.data);
                    elseif length(new_data) + obj.last_valid_I > obj.buffer_size
                        %Example:
                        %keep 20 valid
                        %95 - last_valid_I
                        %we now have 13 new samples
                        %
                        %   13 new samples go in from 20-13+1 to 20
                        %
                        start1 = obj.n_samples_keep_valid-length(new_data)+1;
                        end1 = obj.n_samples_keep_valid;
                        %don't want to pollute data before shuffling
                        %obj.data(start1:end1) = new_data;
                        
                        %
                        %   We still need 7 samples, grab from 95 backwards
                        %           95-n_samples_grab+1:95
                        %
                        n_samples_grab = obj.n_samples_keep_valid-length(new_data);
                        start2 = obj.last_valid_I-n_samples_grab+1;
                        end2 = obj.last_valid_I;
                        
                        obj.data(1:n_samples_grab) = obj.data(start2:end2);
                        %do this after internal shuffling;
                        obj.data(start1:end1) = new_data;
                        
                        obj.last_valid_I = obj.n_samples_keep_valid;
                    else
                        start_I = obj.last_valid_I+1;
                        end_I = obj.last_valid_I+length(new_data);
                        obj.data(start_I:end_I) = new_data;
                        obj.last_valid_I = end_I;
                    end
                    
                    obj.n_seconds_valid = obj.last_valid_I*obj.data_dt;
                    
                    I2 = obj.add_data_times_I;
                    if I2 == 100
                        I2 = 1;
                    else
                        I2 = I2 + 1;
                    end
                    obj.add_data_times(I2) = toc(h_tic);
                    obj.add_data_times_I = I2;
                end
            catch ME
                if ~obj.error_thrown
                    obj.error_thrown = true; %Only throw this once
                    fprintf(2,'error in addData callback, see debug_ME variable in base workspace\n')
                    assignin('base','debug_ME',ME)
                    assignin('base','debug_streaming',obj)
                end
            end
        end
        function user_data = getData(obj)
            last_I = obj.last_valid_I;
            n_valid_goal = obj.n_samples_keep_valid;
            if last_I < n_valid_goal
                user_data = obj.data(1:last_I);
            else
                user_data = obj.data(last_I-n_valid_goal+1:last_I);
            end
        end
        function reset(obj)
            obj.block_initialized = false;
        end
    end
end

function data_vector = h__getData(doc,obj,start_I,n_samples)
AS_DOUBLE = 1;
channel_number_1b = obj.chan_index;
block_number_1b = obj.current_record;

data_vector = doc.h.GetChannelData(...
    AS_DOUBLE,...
    channel_number_1b,...
    block_number_1b,...
    start_I,...
    n_samples);

obj.last_grab_start = start_I;
n_samples2 = length(data_vector);
%TODO: validate length is what we expect if n_samples is not -1
%-1 means grab all
obj.last_grab_end = start_I + n_samples2-1;
end
