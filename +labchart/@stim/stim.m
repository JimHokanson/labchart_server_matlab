classdef stim < handle
    %
    %   Class:
    %   labchart.stim
    %
    %   Reading Values & Stimulator State
    %   ---------------------------------
    %   We don't have access to reading values from the stimulator panel so
    %   all of this code assumes no one has touched anything on the
    %   stimulator panel.
    %
    %   Questions
    %   ---------
    %   1) Does the stimulator panel need to be open?
    
%   ' Begin SetStimulatorValue
% 	outputIndex = 0
% 	paramId = "_Delay6"
% 	value = "0"
% 	unit = "s"
% 	suppressRefresh = False
% 	Call Doc.SetStimulatorValue (outputIndex, paramId, value, unit, suppressRefresh)
% 	' End SetStimulatorValue
% 	
% 	' Begin SetStimulatorValue
% 	outputIndex = 0
% 	paramId = "_Delay6"
% 	value = "2"
% 	unit = "s"
% 	suppressRefresh = False
% 	Call Doc.SetStimulatorValue (outputIndex, paramId, value, unit, suppressRefresh)
% 	' End SetStimulatorValue
% 	
% 	' Begin SetStimulatorValueOptions
% 	outputIndex = 0
% 	paramId = "_PulseWidth5"
% 	minimum = 50
% 	maximum = 1000
% 	normalIncrement = 4.75e-007
% 	useLogSlider = True
% 	useSteps = True
% 	unit = "us"
% 	Call Doc.SetStimulatorValueOptions (outputIndex, paramId, minimum, maximum, normalIncrement, useLogSlider, useSteps, unit)
% 	' End SetStimulatorValueOptions
    
    properties
        h %Interface.ADInstruments_LabChart_1.0_Type_Library.IADIChartDocument
        chan1_enabled = false
        chan2_enabled = false
    end
    
    methods
        function obj = stim(doc)
            %
            %   obj = labchart.stim(doc);
            
            %TODO: 
            
           obj.h = doc.h; 
           
           obj.disableChannels(1:2);
        end
    end
    
    methods
        function enableChannels(obj,channels)
            for i = 1:length(channels)
                cur_channel = channels(i);
                switch cur_channel
                    case 1
                        obj.chan1_enabled = true;
                    case 2
                        obj.chan2_enabled = true;
                    otherwise
                        error('Unsupported channel')
                end
                invoke(obj.h,'SetStimulatorOn',cur_channel-1,true);
            end
        end
        function disableChannels(obj,channels)
            for i = 1:length(channels)
                cur_channel = channels(i);
                switch cur_channel
                    case 1
                        obj.chan1_enabled = false;
                    case 2
                        obj.chan2_enabled = false;
                    otherwise
                        error('Unsupported channel')
                end
                invoke(obj.h,'SetStimulatorOn',cur_channel-1,false);
            end
        end
        function startStimulation(obj)
            invoke(obj.h,'StimulateNow');
        end
        function stopStimulation(obj)
           %
           %    
           
           state = [obj.chan1_enabled,obj.chan2_enabled];
           
           %TODO: I don't know if there is another way of stopping
           %stimulation ...
           obj.disableChannels(1:2);
           
           %Restore state
           %-------------
           if state(1)
               obj.enableChannels(1);
           end
           
           if state(2)
               obj.enableChannels(2);
           end
        end
        function setStimulatorValue(obj,channel_1b,param_id,value,units)
            %
            %   Inputs
            %   ------
            %   channel_1b : numeric
            %   param_id : string
            %   value : numeric or string
            %   units : string
            
            supress_refresh = false;
            
            if isnumeric(value)
                value = sprintf('%g',value);
            end
            
            invoke(obj.h,'SetStimulatorValue',channel_1b-1,param_id,value,units,suppress_refresh);
        end
        function setStimulatorValueOptions(obj)
           error('Not yet implemented')
           % 	' Begin SetStimulatorValueOptions
% 	outputIndex = 0
% 	paramId = "_PulseWidth5"
% 	minimum = 50
% 	maximum = 1000
% 	normalIncrement = 4.75e-007
% 	useLogSlider = True
% 	useSteps = True
% 	unit = "us"
% 	Call Doc.SetStimulatorValueOptions (outputIndex, paramId, minimum, maximum, normalIncrement, useLogSlider, useSteps, unit)
% 	' End SetStimulatorValueOptions
        end
    end
    
end

