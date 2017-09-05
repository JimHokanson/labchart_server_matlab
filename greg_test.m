% greg_test.m
% get used to wroking with the labchart stuff

d = labchart.getActiveDocument;

channel_data_flags = 1; % for double output, 1     (0 for variants output, THIS RETRUNS A CELL ARRAY)
channel_num = 5; % ONE REFERENCED... need to find a way to be able to type in the name of the sample. 
block_num = 15; %just a test number. every time there is a 'start' called is a new block. 
        % i think block_num is zero referenced... so this value is one less
        % than the number of the block.
start_sample = 1; % for now grab from start. How to convert from time to samples?


%{
sampling_period = d.h.GetRecordSecsPerTick(block_num); 
FS = 1/sampling_period;

num_samples_in_block = d.h.GetRecordLength(block_num);
block_duration = num_samples_in_block*sampling_period; %seconds

block_start_date = d.h.GetRecordStartDate(block_num);


num_samples = 10000; %what happens if too many? can I find out how many there are?

%d.channel_names gives the current channel names. are they in order of
%channel number??
%}
data = d.h.GetChannelData(channel_data_flags, channel_num, block_num, start_sample, num_samples);
plot(data)




% right now, seems that I can add a comment, but I don't know how to get
% the comments out of the data


% methods(d)
% look at the documentation
% methods(d.h) methods of underlying com object
% events(d.h)
%  fieldnames(d.h)

%{
invoke(d.h, 'SetStimulatorWaveform', 0, 'ScopeBiphasic')
GetChannelData
run the macro, can see calls
%}