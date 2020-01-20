# Matlab Interface to the LabChart Server

This code controls parts of LabChart, from Matlab. Unlike the ADInstruments SDK ([matlab](https://github.com/JimHokanson/adinstruments_sdk_matlab),[python](https://github.com/JimHokanson/adinstruments_sdk_python)), the focus of this repo is on controlling Labchart directly, rather than reading files.

Work on this library is incomplete. It does what I need and I have little interest in polishing it up more. I started implementing stimulator control code, but shortly thereafter acquired a different stimulator that didn't interface with Labchart. The result is that there is some stimulator control code but in this library but it is a bit disorganized. Documentation for the underlying interface is minimal from ADInstruments, which has meant a rather ad-hoc design approach. 

All that being said, I am happy to entertain issues (post on GitHub) or requests for improvement.  

## Examples ##

### Adding a Comment ###

```matlab
doc = labchart.getActiveDocument();
doc.addComment('Testing');
```

### Data Retrieval ###

```matlab
doc = labchart.getActiveDocument();

%Requesting based on samples
%---------------------------
block_number = 1;
start_sample = 1;
end_sample = 1000;
data = doc.getChannelData('my_channel',block_number,start_sample,end_sample);

%Using time instead of samples
%-----------------------------
chan_number = 1; %1 based
start_time = 0;
end_time = 230; %seconds
[data,time] = d.getChannelData(chan_number,block_number,0,230,'as_time',true)
```

The underlying interface has three issues that the user should be aware of:
1. All data are sampled at the same rate, even if the data are saved to disk at different rates. Thus if you have two channels, one sampled at 10 Hz, and another at 1000 Hz, if you request 1 seconds worth of data from the first channel (10 Hz) you'll get 1000 samples, not 10. In these instances all data are returned in a sample-and-hold format. In other words, for the 10 Hz channel, values will only change at 10 Hz; all other values are repeats (held values) of the changed value.
2. My software could optionally hide this sample-and-hold behavior, but there is no way of knowing for sure what the sampling rate is of each channel. I could try and detect this based on finding repeat values, but I haven't implemented this feature.
3. The file reading SDK does not provide the ability to read calculated channels, i.e. channels that are simply mathematical derivations of input channels. For example, one channel could simply be another channel after filtering. This repo allows the user to request these calculated channels.

### Time Information ###

One approach I've used the library for is to request data for stimulus triggered averaging. To implement the averaging we need to know when our stimuli are delivered. My stimulus software automatically generates comments that get added to the file for record keeping purposes. However, as far as I can tell this interface does not allow requesting the time of a comment. Thus one must log the current time when making requests.

```matlab
doc = labchart.getActiveDocument();
current_record = doc.current_record; %-1 if not sampling
n_ticks = doc.getRecordLengthInTicks(current_record);
```

If we log a start "time" (record # and tick #) and stop time then we can request data within this time window for averaging. I personally will record sync pulses to know when stimuli occurred. Additionally, I log stimulus specific information internally in my Matlab program so that I can chop up the averages any way that I'd like.


### Streaming and Callbacks ###

Labchart provides allows you to register callbacks for at least 4 events:
- starting a block
- ending a block
- when new samples have been collected
- when a new data selection occurs

```matlab
doc = labchart.getActiveDocument();
%This is an example callback which simply prints the # of new samples acquired ...
doc.registerOnNewSamplesCallback(@labchart.callbacks.newData);
```

I've implemented a class that stores a specified # of seconds worth of data as it comes in from Labchart. Here's an example:

JAH TODO

## Requirements

LabChart must be installed on the computer running this code.

## COM Server Background

This section contains information on how to write more code for the repo, particularly more code that interacts with the COM server.

AD Instruments provides a COM server for LabChart that allows sending commands to LabChart. This code wraps calls to that server. Documentation for this server is minimal, and code development so far has relied largely on trial and error with a running LabChart instance. 

"Documentation" of some methods can be found in Excel. This can be done via:

1. Open Excel
2. Press 'alt+F11'
3. Select menu => tools => references
4. Check the box for AD Instruments
5. Select menu => view => object browser
6. Go to the top of the window and select 'ADIChart'

Additional methods can be discovered by recording macros in LabChart. For methods not obviously exposed to Matlab (i.e. seen by calling methods() on the COM instance), the invoke() command can also be used.

Most Matlab objects in this package have a 'h' property, which is the handle to the actual COM object. 



