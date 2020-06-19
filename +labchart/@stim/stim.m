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
    %   1) Does the stimulator panel need to be open? - it doesn't seem
    %   like it
    %
    %   Improvements
    %   ------------
    %   1) Provide an initialize command which sets everything to known
    %   values so that we can internally track all values.
    
    
    %{
    
    %Example Code
    %------------------------
    d = labchart.getActiveDocument;
    w = d.stimulator.setStimulatorWaveform(1, 'pulse'); %set channel 1 to biphasic
    w.setBaseline(0);
    w.setStartDelay(0, 's');
    w.setNPulses(-1);
    w.setPulseRate(10,'Hz')
    JAH TODO: Finish this ...
    
    %}
    
    
    
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
    


    % Examples:
    %{
        doc = labchart.getActiveDocument();
        s = doc.stimulator
        s.setStimulatorWaveform(1, 'biphasic_pulse')
    %} 
    properties
        h %Interface.ADInstruments_LabChart_1.0_Type_Library.IADIChartDocument
        
        d0 = '----- options -------'
        allow_null_ops = true
        %If this is true, where possible we should check locally
        %for the current value and not run a command unless we need to.
        %
        %This will run into problems if the user ever changes the
        %parameters on the GUI. Note that we can technically run the
        %stimulator without the stimulator window being open.
        
        d1 = '------ read only ------'
        %This is kept track of internally but might be invalid
        %if the user changes anything sine we can't read properties ...
        chan1_enabled = false
        chan2_enabled = false
        differential_enabled = []
        chan1_user_waveform_name = ''
        chan1_internal_waveform_name = ''
      	chan2_user_waveform_name = ''
        chan2_internal_waveform_name = ''
        
        %This does not include custom options
        waveform_options = {'Arithmetic Pulse','Pulse','Step','Step Pulse','Biphasic Pulse',...
            'Double Pulse','Ramp','Sine','Triangle'};
        
        waveform1 % class which holds all of the parameters of the waveform
        waveform2
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
            %
            %   startStimulation(obj)
            %
            %   Example
            %   -------
            %   obj.startStimulation()
            
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
            
            suppress_refresh = false;
            
            if isnumeric(value)
                value = sprintf('%g',value);
            end
            
            invoke(obj.h,'SetStimulatorValue',channel_1b-1,param_id,value,units,suppress_refresh);
        end
        function setCustomWaveform(obj,channel_1b,custom_waveform_name)
            
            %Technically we could do this in setStimulatorWaveform
            %but then we wouldn't get error checking
            
            error('Not yet implemented') 
            %needs channel and logging
            invoke(obj.h,'SetStimulatorWaveform',out_name);
        end
        function setDifferential(obj,value)
            %
            %   setDifferential(obj,value)
            %true or false
            
            if obj.allow_null_ops && isequal(value,obj.differential_enabled)
                return
            end
            % if the val we are requesting is equal to the val we think it
            % already is, just skip the command to avoid starting a new
            % block -- ideally implement this in all methods!
            
            %I don't think channel matters since toggling either
            %links or unlinks both channels.
            channel_0b = 0;
            invoke(obj.h,'SetStimulatorDifferential',channel_0b,value);
            obj.differential_enabled = value;
        end
        function waveform = setStimulatorWaveform(obj,channel_1b,waveform_name)
            %
            %   setStimulatorWaveform(obj,channel_1b,name)
            %
            %   obj.setStimulatorWaveform(1,'Biphasic Pulse');
            %   obj.setStimulatorWaveform(1,'Pulse');
           
            switch lower(waveform_name)
                case 'arithmetic pulse'
                    out_name = 'ArithmeticPulses1';
                case 'pulse'
                    out_name = 'LegacyPulse';
                case 'step'
                    out_name = 'LegacyStep';
                case 'step pulse'
                    out_name = 'LegacyStepPulse';
                case 'biphasic pulse'
                    out_name = 'ScopeBiphasic';
                case 'double pulse'
                    out_name = 'ScopeDoublePulse';
                case 'ramp'
                    out_name = 'ScopeRamp';
                case 'sine'
                    out_name = 'ScopeSine';
                case 'triangle'
                    out_name = 'ScopeTriangle';
                otherwise
                    error('Waveform Option not recognized')
            end
                
            
            
            if channel_1b == 1
                int_name = obj.chan1_internal_waveform_name;
            else
                int_name = obj.chan2_internal_waveform_name;
            end
            
            %Setting the waveform can cause a new block to form
            %We try and avoid this ...
            %But since we are running open loop, we might want to always do
            %this ...
            if obj.allow_null_ops && strcmp(int_name,out_name)
                return
            end
            
            switch lower(waveform_name)
                case 'biphasic pulse'
                    waveform = labchart.stim_waveforms.biphasic_pulse(obj.h, channel_1b-1);
                case 'pulse'
                    waveform = labchart.stim_waveforms.pulse(obj.h, channel_1b-1);
                otherwise
                    error('Not yet implemented')
            end
            
            if channel_1b == 1
                obj.waveform1 = waveform;
                obj.chan1_user_waveform_name = lower(waveform_name);
                obj.chan1_internal_waveform_name = out_name;
            else
                obj.waveform2 = waveform;
                obj.chan2_user_waveform_name = lower(waveform_name);
                obj.chan2_internal_waveform_name = out_name;
            end
            
            invoke(obj.h,'SetStimulatorWaveform',channel_1b-1,out_name);
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

% ' Name:        SetStimulatorValueOptions
% ' Description: Changes the settings of a parameter that is
% '              currently being used by an ouput.
% ' Parameters:  outputIndex     - index of the output that the
% '                                parameter is bound to (the
% '                                first output has index
% '                                zero),
% '              paramId         - id of the parameter,
% '              minimum         - minumum value for the
% '                                parameter in the units set
% '                                by the 'unit' argument,
% '              maximum         - maxumum value for the
% '                                parameter in the units set
% '                                by the 'unit' argument,
% '              normalIncrement - increment value for the
% '                                parameter in the units set
% '                                by the 'unit' argument,
% '              useLogSlider    - true if this parameter
% '                                should use a logarithmic
% '                                scale on the value slider,
% '              useSteps        - true if the parameter should
% '                                calculate it's increment
% '                                value from a number of
% '                                steps,
% '              unit            - the unit to use for this
% '                                parameter (case sensitive)
% ' 
% ' Begin SetStimulatorValueOptions
% outputIndex = 0
% paramId = ""
% minimum = 0
% maximum = 0
% normalIncrement = 0
% useLogSlider = False
% useSteps = False
% unit = ""
% Call Doc.SetStimulatorValueOptions (outputIndex, paramId, minimum, maximum, normalIncrement, useLogSlider, useSteps, unit)
% ' End SetStimulatorValueOptions





        end
    end
    
end

%{
OpenStimulatorDialog - ?
OpenStimulatorPanel
SetOutputEnabled_Independent - Sets whether an output is enabed (as opposed to
'              currently turned on).
x SetStimulatorDifferential
SetStimulatorIsolated Select between isolated and analogue outputs.
'              Only use this macro if a stimulus isolator is
'              connected and it can be disabled.
SetStimulatorOn - Change the On/Off state of the output.
SetStimulatorOutputRangeIndex
SetStimulatorStartMode - 
' Description: Sets the stimulator start mode.
' Parameters:  mode - can be any of the following:
'                     kStartWhenSamplingStarts,
'                     kStartManually,
'                     kStartIndependentlyOfSampling
SetStimulatorValueOptions
SetStimulatorValueWholeNumber
SetStimulatorWaveform
StimulateNow
StimulatorStopped - Show independent stimulus stopped message box


%}
