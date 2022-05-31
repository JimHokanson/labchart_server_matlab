# Streaming #

LabChart supports streaming via an event called `OnNewSamples`. This event is not channel specific. It gets called maybe every 50 ms (need to check this). When it is called, it doesn't actually pass in the data, it just says that new samples are available (and how many). It is then up to the user to request this data via other methods.

To make it simpler to work with streaming data, I have created a class called `streamed_data1` in the `labchart.streaming` packages. Calling this class thus needs to be done by calling `labchart.streaming.streamed_data1`. The fact that this is a class in a package is not critical to understand for using this code. The suffix of `1` is simply used to indicate that this is one implementation of streaming code. I'll note that this class makes it easier (I think) for working with streaming data, but one could also use the underlying calls to the LabChart COM server.

In the next sections I'll describe what this code does. If you want you can skip to the usage section below although the following sections may be useful for understanding what is going on.

# Data Initialization #

As far as I know MATLAB doesn't have a streaming data interface. Every time an array grows it needs to get new memory for the larger array. To get around this it is best to pre-initialize an array. So for example we might initialize an array to hold 1 million values, and then as samples are collected, we start to fill our 1-million sample array.

The question then is what to do when we have more samples. Here there are at least two options.
1. Increase the buffer size by some amount. Note, the goal is to increase the size by an amount that will hold all future samples. This estimate may be inaccurate, and further resizing may be needed, but this is different than resizing the array every time there is new data.
2. Recycle the buffer. With this approach we only hold on to the latest 'N' samples. With this approach no resizing occurs, however we aren't able to hold on to all of the data. `streamed_data1` uses this approach.

Parameters:
- **n_seconds_keep_valid** - This is an input to the constructor (i.e., must be specified). This is how many samples (specified in units of time/seconds) you want to be able to retrieve at any given point.
- **buffer_muliplier** - (default 10) This is an optional parameter that somewhat exposes the internal workings of the code. Basically the actually allocated buffer size is this much greater than the `n_seconds_keep_valid` input. Currently this also specifies how much data gets plotted. So for example if we do `n_seconds_keep_valid=5` and `buffer_muliplier=10` we will only ever see 50 seconds worth of data. Eventually these two things will be unlinked.

Note, this buffer is wiped/reinitialized on Block/Record change. This behavior can be changed by setting `auto_detect_record_change` to `true`.

# Data Retrieval #

Internally we keep track of the last retrieved time. When new samples occur, we first make sure the buffer is initialized. Then we request all samples up to the current time. Note, this ignores how many new samples have been specified. Thus if we are at sample 100 in the buffer, and the latest sample LabChart has is 1000, then we request 900 more samples.

All data are returned at the highest sampling rate. Channels that are not sampled at that rate return data held at a constant so that the values only change at the specified sampling rate. In other words, if the highest sampling rate was 10 Hz and the channel was sampled at 1 Hz, when requesting that channel's data, you will see 10 samples per second, but all of the samples have the same value. The data can be simplified down to the original sampling rate by setting the parameter `remove_sample_hold` to `true`.

Parameters:
- **remove_sample_hold** - (default true) If true, all redundant samples are removed and the channel's sampling rate matches what is specified in LabChart. If false, the channel contains enough samples to match the fastest sampled channel (referred to as the tick rate in LabChart code), with repeat values (i.e., the channel is sampled and held).

# Processing & Plotting #

The next three steps are as follows:
1. An optional callback for doing something to the data before plotting, `new_data_processor`
2. Optional plotting
3. An optional callback for doing something to the data AFTER plotting, `new_data_processor2`. This allows you to plot the data one way, but to store/process the data in another way. More on "processing" in the next section. The data are only added to the buffer after this call.

I'm not thrilled with the names, but it works. 

The callbacks should take two arguments. The first is the newly received data and the second is a flag indicating whether or not the buffer has been reset. This reset could be either due to just starting out or due to a new block being initialized.

Currently only 1 processor has been pre-defined, that is a Butterworth filter.

```
%Let's filter the incoming data for s1
%order,cutoff,sampling_rate,type
filt_def = labchart.streaming.processors.butterworth_filter(2,5,fs,'low');
%s1 is our streaming object ...
s1.new_data_processor = @filt_def.filter;
```

Note we are passing in a method of the class with the instance bound to it. This allows us to reference the variables (filter parameters) we used to create the class. 

Parameters:
- **new_data_processor**
- **new_data_processor2**


## Plotting ##

For plotting we use an `animatedline` class. It is designed to support adding on new points relatively quickly. I have faster code (https://github.com/JimHokanson/plotBig_Matlab), but it is overkill for most situations. Anyway, as a reminder the buffer size of this class is set to the same as the buffer size we use internally to hold onto the data. At some point this may change.

To enable plotting, an axes handle must be passed into the streaming object constructor as an optional input (see usage section below). In addition, we can pass in line plot options (variable: `plot_options`) that specifies how to format the line.

Parameters:
- **h_axes** - handle to the axes to plot into
- **plot_options** - cell array of property/value pairs, e.g., `{'Linewidth',3,'Color','r'}`
- **axis_width_seconds** - # of seconds to show on the plot. Note, this does not control how much data is available for plotting. Currently this is controlled by `buffer_muliplier` although that may change ...


# Callbacks #

In summary, thus far we have:
- received new data
- it has optionally been downsampled
- it has optionally been processed, plotted, and processed some more
- it has been stored into our buffer

At this point we may wish to do something with the acquired data, besides plotting it. Enter,  the callback. The callback should accept two arguments. The first is the streaming object, and the second is a handle to the LabChart document.

- Argument 1: `labchart.streaming.streamed_data1`
- Argument 2: `labchart.document`

Some example callbacks are provided in `labchart.streaming.callback_examples` as static methods (see usage below).

The primary functions and properties to access from the streaming data object are:
- **.n_seconds_valid** - a property indicating how much data is valid. Currently this will only ever be somewhere from 0 to the # of seconds requested, despite the buffer being larger ...
- **getData()** - This method returns arrays of data and time. You can do with it what you want!
- **.user_data** - You can store whatever you want in this property.
- **.new_data** - This is the latest data acquired ..._

Parameters:
- **callback_only_when_ready** - Here "ready" indicates that we have met or exceeded the requested # of samples to keep valid at a time. 


# Usage #

```matlab
%Example
%-------
d = labchart.getActiveDocument();

%Setup plotting
%------------------
clf %We'll setup for 3 channels ...
h1 = subplot(3,1,1);
h2 = subplot(3,1,2);
h3 = subplot(3,1,3);

%Initialize Streams
%------------------
fs = 1000; %frequency of sampling (sampling rate)
fs2 = 20000;
n_seconds_valid = 10;
%fs,n_seconds_keep_valid,chan_index_or_name
s1 = labchart.streaming.streamed_data1(fs,n_seconds_valid,'void volume low pass ','h_axes',h1,'plot_options',{'Color','r'},'axis_width_seconds',20);
s2 = labchart.streaming.streamed_data1(fs,n_seconds_valid,'bladder pressure','h_axes',h2,'plot_options',{'Color','g'},'axis_width_seconds',20);
s3 = labchart.streaming.streamed_data1(fs2,n_seconds_valid,'stim1','h_axes',h3,'plot_options',{'Color','b'},'axis_width_seconds',20);

%Note, by default we hold onto 10x n_seconds_valid for plotting

%Let's filter the incoming data for s1
%order,cutoff,sampling_rate,type
filt_def = labchart.streaming.processors.butterworth_filter(2,5,fs,'low');
s1.new_data_processor = @filt_def.filter;

%<function_name>(streaming_obj,doc)
s1.callback = @labchart.streaming.callback_examples.nValidSamples;
%Alternatively
s1.callback = @labchart.streaming.callback_examples.averageSamplesAddComment;

%Store whatever you want here. You can use this in the callback by
%accessing this property from the first input argument.
s1.user_data = 'hello!';

%This registers all streaming objects for callbacks
%
%Note, in this case the adding/plotting/calback will execute for s1 first, followed by 
%s2 then s3
s1.register(d,{s2,s3})

%Use this if you only want one channel
s1.register(d)

%------------------------------------

%To stop the events
%-------------------
d.stopEvents() 
```

```
function averageSamplesAddComment(stream_obj,h_doc)
    persistent h_tic

    %Output every 5 seconds
    if isempty(h_tic) 
        h_tic = tic;
    else
        if toc(h_tic) > 5
            h_tic = tic;
            [data,time] = stream_obj.getData();
            h_doc.addComment(sprintf('Mean %g starting at %g',mean(data),time(1)));
        end
    end
end
```


