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
        buffer_muliplier
        callback
        callback_only_when_ready
        h_axes
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
            obj.plot_options = in.plot_options;
            obj.remove_sample_hold = in.remove_sample_hold;
        end
        %TODO: Can we do a specific unregister call?
        %       - in other words, currently the only unregister we call
        %       is for everything, can we be more precise?
        %TODO: What happens if we register twice???
        function register(h_doc)
            %
            %   Makes it so that on new samples we add them to the class
            fh = @(varargin)obj.addData(h_doc);
            h_doc.registerOnNewSamplesCallback(fh);
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
            obj.error_thrown = false;
        end
    end
end


