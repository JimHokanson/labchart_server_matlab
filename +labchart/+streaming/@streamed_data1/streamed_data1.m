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
    %          |------------------------------------|    <= buffer
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
    %
    %   Add Data Outline/Hooks
    %   -------------------------------------------------------------------
    %   - Initialization
    %   - Removing sample and hold
    %   - new_data_processor() <= if exists
    %   - plotting new data <= if plot exists
    %   - new_data_processor2() <= if exists
    %
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
    %   1) Support downsampling beyond simply removing the sample and hold 
    %      data.
    %
    %   Example
    %   -------
    %   d = labchart.getActiveDocument();
    %
    %   %Setup plotting
    %   %------------------
    %   clf
    %   h1 = subplot(3,1,1);
    %   h2 = subplot(3,1,2);
    %   h3 = subplot(3,1,3);
    %
    %   %Initialize Streams
    %   %------------------
    %   fs = 1000;
    %   fs2 = 20000;
    %   n_seconds_valid = 10;
    %   %fs,n_seconds_keep_valid,chan_index_or_name
    %   s1 = labchart.streaming.streamed_data1(fs,n_seconds_valid,'void volume low pass ','h_axes',h1,'plot_options',{'Color','r'},'axis_width_seconds',20);
    %   s2 = labchart.streaming.streamed_data1(fs,n_seconds_valid,'bladder pressure','h_axes',h2,'plot_options',{'Color','g'},'axis_width_seconds',20);
    %   s3 = labchart.streaming.streamed_data1(fs2,n_seconds_valid,'stim1','h_axes',h3,'plot_options',{'Color','b'},'axis_width_seconds',20);
    %
    %   %Note, by default we hold onto 10x n_seconds_valid for plotting
    %
    %   %Let's filter the incoming data for s1
    %   %order,cutoff,sampling_rate,type
    %   filt_def = labchart.streaming.processors.butterworth_filter(2,5,fs,'low');
    %   s1.new_data_processor = @filt_def.filter;
    %   
    %   %TODO: Add on s2 example ...
    %
    %   %<function_name>(streaming_obj,doc)
    %   s1.callback = @labchart.streaming.callback_examples.nValidSamples;
    %   %Alternatively
    %   s1.callback = @labchart.streaming.callback_examples.averageSamplesAddComment;
    %   
    %   
    %   s1.register(d,{s2,s3})
    %
    %   s1.register(d,s2)
    %
    %
    %
    %
    %   %When done ...
    %   %----------------------
    %   d.stopEvents
    
    properties
        user_data %Put whatever you want in here ...
        
        data %The buffer of data. Once a sufficient time has elapsed it
        %will always keep at least 'n_seconds_keep_valid' worth of data
        
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
        buffer_muliplier
        callback %<function_name>(streaming_obj,doc)
        callback_only_when_ready
        h_axes
        plot_options
        new_data_processor %data_out = <function_name>(data_in,is_first_call)
        new_data_processor2 %data_out = <function_name>(data_in,is_first_call)
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
        error_ME
        
        %TODO: Do we want to hold onto the data at each stage of the
        %processing - we could make this behavior optional
        %new_raw
        %new_after_p1
        %new_after_p2
        
        
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
        n_simple_adds = 0
        n_buffer_resets = 0
        n_add_data_calls = 0
        ms_per_callback = zeros(1,100)
        ms_since_last_callback = zeros(1,100)
        n_samples_added = zeros(1,100);
        perf_I = 0
        last_callback_time = []
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
            %   auto_detect_record_change : default true
            %       If true, changes in record will automatically
            %       reinitialize this class. Generally this should be left
            %       true ...
            %   axis_width_seconds : default []
            %       If specified this will update the range of the x-axis
            %       so that it spans the spcecified width.
            %   buffer_muliplier : default 10
            %       How big to make the buffer relative to the amount
            %       of data we want to ensure is always valid. Once the
            %       buffer is about to overflow we move the necessary
            %       amount of data to the front of the buffer. Thus this
            %       parameter is a speed/memory tradeoff; smaller means
            %       more moving memory around, larger means slightly faster
            %       performance but more overall memory usage. This also
            %       impacts how much data are retained when plotting (if
            %       h_axes is specified).
            %   callback : default []
            %       If specified this will be called after the internal
            %       buffer has been updated with the newest data.The 
            %       format should be:
            %
            %           <function_name>(streaming_obj,doc)
            %               - streaming_obj - this class
            %               - doc - handle to the Labchart document
            %                       labchart.document
            %
            %
            %   callback_only_when_ready : default true
            %   h_axes : handle to Axes object
            %       If specified, the buffer will be plotted to the
            %       specified axes object as new data are acquired. The
            %       underlying implementation uses animatedline() with a
            %       maximum size set to the size of the buffer.
            %   new_data_processor : callback
            %       If passed in, this callback receives new data and
            %       should return processed data. This can be used to
            %       filter data as it is acquired. Format must be:
            %           
            %           data_out = <function_name>(data_in,is_first_call)
            %
            %       Note that 'is_first_call' is true when the underlying
            %       buffer has just been initialized (or re-initialized).
            %   new_data_processor2 : callback
            %       Same as new_data_processor() but occurs after plotting
            %       rather than before ...
            %   plot_options : cell
            %       Pass this in to control properties of plotting. For
            %       example you could pass in {'color','r'}
            %   remove_sample_hold : (default true)
            %       If true, replication due to sample & hold is removed. 
            %       All channels except the highest rate channel will
            %       return data at the high rate with values sampled and
            %       held at the specified channel sampling rate. For
            %       example if we sample at 10Hz but our highest rate is
            %       100 Hz by default we'll get 100Hz data with changes
            %       every 10th sample
            %   remove_sample_hold : (default true)
            %       If true, redundant samples from holding will be
            %       removed so that the sampling rate becomes the specified
            %       sampling rate. If false, the sampling rate is
            %       equivalent to the highest sampling rate being used in
            %       the file.
            %
            %   Example
            %   -------
            %   d = labchart.getActiveDocument();
            %   name = 'void volume low pass ';
            %   fs = 1000;
            %   n_seconds_valid = 10;
            %   s1 = labchart.streaming.streamed_data1(fs,n_seconds_valid,name,...
            %       'h_axes',gca,'plot_options',{'Color','r'});
            %   s1.register(d);
            
            in.auto_detect_record_change = true;
            in.axis_width_seconds = [];
            in.buffer_muliplier = 10;
            in.callback = [];
            in.callback_only_when_ready = true;
            in.h_axes = [];
            in.new_data_processor = [];
            in.new_data_processor2 = [];
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
            obj.callback = in.callback;
            obj.callback_only_when_ready = in.callback_only_when_ready;
            
            obj.h_axes = in.h_axes;
            obj.new_data_processor = in.new_data_processor;
            obj.new_data_processor2 = in.new_data_processor2;
            obj.plot_options = in.plot_options;
            obj.remove_sample_hold = in.remove_sample_hold;
        end
        %TODO: Can we do a specific unregister call?
        %       - in other words, currently the only unregister we call
        %       is for everything, can we be more precise?
        %TODO: What happens if we register twice???
        function pipeline = getPipeline(obj)
            
            pipeline = {'Data requested from Labchart'};
            if obj.decimation_step_size ~= 1
                pipeline = [pipeline; ...
                    sprintf('Removing sample/hold, keeping every %d sample',obj.decimation_step_size)];
            end
            
            if ~isempty(obj.new_data_processor)
                pipeline = [pipeline; 
                    sprintf('Processing new data before plotting with %s',func2str(obj.new_data_processor))];
            end
            
            if isvalid(obj.h_axes)
               %TODO: Really we need a switch on whether initialized or not
               %if initialized we need to check line status
               pipeline = [pipeline; 
                    'Plotting new data'];
            end
            
            if ~isempty(obj.new_data_processor2)
                pipeline = [pipeline; 
                    sprintf('Processing new data after plotting with %s',func2str(obj.new_data_processor2))];
            end
            
            pipeline = [pipeline; 
                    'Data added to buffer'];
                
            if ~isempty(obj.callback)
                pipeline = [pipeline; 
                    sprintf('Callback after data has been placed in buffer: %s',func2str(obj.callback))];
            end    
        end
        function register(obj,h_doc,other_streams)
            %
            %   register(obj,h_doc,*other_streams)
            %
            %   This registers this stream with the document so that new
            %   samples are added to this stream
            %
            %   Optional Inputs
            %   ---------------
            %   other_streams : cell array
            %       Other streams that should also be registered in the
            %       same callback. Order of execution of the adding is:
            %           - this stream first
            %           - the other streams, first to last
            
            if nargin == 2
                fh = @(varargin)obj.addData(h_doc);
                h_doc.registerOnNewSamplesCallback(fh);
            else
                h__registerMultipleStreams(obj,h_doc,other_streams)
            end
        end
        
        function [user_data,time] = getData(obj)
            %TODO: Add time
            last_I = obj.last_valid_I;
            n_valid_goal = obj.n_samples_keep_valid;
            if last_I < n_valid_goal
                user_data = obj.data(1:last_I);
            else
                user_data = obj.data(last_I-n_valid_goal+1:last_I);
            end
            
            if nargout == 2
%             x1 = obj.last_grab_start/obj.ticks_per_second;
%             x2 = obj.last_grab_end/obj.ticks_per_second;
%             x = x1:obj.data_dt:x2;
                n_samples_data = length(user_data);
                
                %Let's say our step size is 10
                %grabbed from 11 to 60
                %1,11,21,31,41,51  <= samples we've kept
                %   1  2  3  4  5  <= indices for our grab (5 samples
                %   keeping)
                %
                %
                %s2 = 60 - 10 + 1 => 51
                %s1 = 51 - 10*(5-1)
                %     51 - 40 => 11
                
                s2 = obj.last_grab_end; %This is slightly off if we decimate
                s2 = s2 - obj.decimation_step_size+1;
                s1 = s2 - obj.decimation_step_size*(n_samples_data-1);
                
                %Samples to time ...
                x1 = s1/obj.ticks_per_second;
                x2 = s2/obj.ticks_per_second;
                
                time = x1:obj.data_dt:x2;
                
                
            else
                time = [];
            end
        end
        function reset(obj)
            %??? reset performance???
            obj.block_initialized = false;
            obj.error_thrown = false;
            obj.h_tic_start = [];
        end
    end
end

function h__registerMultipleStreams(obj,h_doc,other_streams)
%
%   TODO: Document this ...
%
%   See Also
%   --------
%   h__newSamplesCallbackMultipleStreams
if ~iscell(other_streams)
    other_streams = num2cell(other_streams);
end
    
all_streams = [{obj} other_streams];

fh = @(varargin)h__newSamplesCallbackMultipleStreams(h_doc,all_streams);
h_doc.registerOnNewSamplesCallback(fh);

end

function h__newSamplesCallbackMultipleStreams(h_doc,streams)
%
%   TODO: Document this
%
%   This is the actuall callback, which calls addData for each stream
    for i = 1:length(streams)
        cur_stream = streams{i};
        cur_stream.addData(h_doc)
    end
end

