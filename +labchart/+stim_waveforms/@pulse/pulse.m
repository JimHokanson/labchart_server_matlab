classdef pulse < handle
    %
    %   Class:
    %   labchart.stim_waveforms.pulse
    %
    %
    
    %   Visible Parameters
    %   ------------------
    %   - Pulse Height
    %   - Pulse Width
    %   
    %   Hidden Parameters
    %   ------------------
    %   - n_pulses
    
    %DOCUMENTATION is old - TODO: update
    
    %   Call Doc.SetStimulatorWaveform(1, "ScopeBiphasic")
    %
    %
    %   calling form for setting the stimulation parameters:
    %   invoke(obj.h, 'SetStimulatorValue', outputIndex, paramId, value, unit, supressRefresh);
    
    properties (Hidden)
        h  %Interface.ADInstruments_LabChart_1.0_Type_Library.IADIChartDocument
        % see the github! See the excel documentation!
        chan %0 based
    end
    properties
        %Global Props: TODO: Add as a mixin
        baseline     % Baseline
        start_delay  % Start Delay
        
        n_repeats     % Repeats % if -1, set to infinit repeats. Otherwise, it is a string with the number of repeats
        max_repeat_rate
        
        %------------------------------------
        
        pulse_amplitude %Pulse Height
        pulse_width % Pulse Width
        sync_chan %Marker Channel
        
        
        supress_refresh
    end
    methods
        function obj = pulse(h,chan)
            obj.h = h;
            obj.chan = chan;
            obj.supress_refresh = false;
        end
        function setBaseline(obj,value)
            unit = 'V'; % cannot change
            obj.baseline = labchart.stim_waveforms.value_and_unit(value, unit);
            parameter = '_Baseline';
            obj.h__SetStimulatorValue(parameter, obj.baseline)
        end
        function setStartDelay(obj,value, unit)
            % % units can be s, ms, or us
            allowed_units = {'s', 'ms', 'us'};
            if ~ismember(unit, allowed_units)
                error('input unit is not allowed')
            end
            
            obj.start_delay = labchart.stim_waveforms.value_and_unit(value, unit);
            
            parameter = '_StartDelay';
            obj.h__SetStimulatorValue(parameter, obj.start_delay);
        end
        function setNRepeats(obj,value)
            % unitless
            % a value of '-1' indicates infinite repeats
            unit = '';
            obj.n_repeats = labchart.stim_waveforms.value_and_unit(value, unit);
            parameter = '_WaveformRepeat';
            obj.h__SetStimulatorValue(parameter, obj.n_repeats);
        end
        
        function setMaxRepeatRate(obj,value, unit)
            allowed_units = {'s', '\min', 'Hz'};
            if ~ismember(unit, allowed_units)
                error('input unit is not allowed')
            end
            
            obj.max_repeat_rate = labchart.stim_waveforms.value_and_unit(value, unit);
            
            parameter = '_MaxRepeatRate';
            obj.h__SetStimulatorValue(parameter, obj.max_repeat_rate);
        end
        
        %-----------------------------------------------------------------------
        function setNPulses(obj,value)
            
            unit = ''; %no units
            parameter = '_BurstRepeat1';
            
            temp = labchart.stim_waveforms.value_and_unit(value, unit);
            obj.h__SetStimulatorValue(parameter, temp);
            %{
            
%Setting to infinity
            	' Begin SetStimulatorValue
	outputIndex = 0
	paramId = "_BurstRepeat1"
	value = "-1"
	unit = ""
	suppressRefresh = False
	Call Doc.SetStimulatorValue (outputIndex, paramId, value, unit, suppressRefresh)
	' End SetStimulatorValue
	

	%Setting to 2
	' Begin SetStimulatorValue
	outputIndex = 0
	paramId = "_BurstRepeat1"
	value = "2"
	unit = ""
	suppressRefresh = False
	Call Doc.SetStimulatorValue (outputIndex, paramId, value, unit, suppressRefresh)
	' End SetStimulatorValue
            
%}            
            
            
            
            
        end
        function setPulseAmplitude(obj,value)
            unit = 'V'; % Volts, V, always!
            parameter = '_PulseHeight1';
            
            obj.pulse_amplitude = labchart.stim_waveforms.value_and_unit(value, unit);
            obj.h__SetStimulatorValue(parameter, obj.pulse_amplitude);
        end
        function setPulseWidth(obj,value, unit)
            %us, ms, s
            
            allowed_units = {'s', 'us', 'ms'};
            if ~ismember(unit, allowed_units)
                error('input unit is not allowed')
            end
            obj.pulse_width = labchart.stim_waveforms.value_and_unit(value, unit);
            
            parameter = '_PulseWidth1';
            obj.h__SetStimulatorValue(parameter, obj.pulse_width);
        end
        function setEndDelay(obj,value,unit)
            
           	allowed_units = {'s', 'us', 'ms'};
            if ~ismember(unit, allowed_units)
                error('input unit is not allowed')
            end
            temp = labchart.stim_waveforms.value_and_unit(value, unit);
            
            parameter = '_EndDelay1';
            obj.h__SetStimulatorValue(parameter, temp);
            
            
            
            %{
           	' Begin SetStimulatorValue
            outputIndex = 0
            paramId = "_EndDelay1"
            value = "5"
            unit = "s"
            suppressRefresh = False
            Call Doc.SetStimulatorValue (outputIndex, paramId, value, unit, suppressRefresh)
            ' End SetStimulatorValue

            ' Begin SetStimulatorValueOptions
            outputIndex = 0
            paramId = "_EndDelay1"
            minimum = 0
            maximum = 10000
            normalIncrement = 100
            useLogSlider = False
            useSteps = True
            unit = "ms"
            Call Doc.SetStimulatorValueOptions (outputIndex, paramId, minimum, maximum, normalIncrement, useLogSlider, useSteps, unit)
            ' End SetStimulatorValueOptions

            ' Begin SetStimulatorValue
            outputIndex = 0
            paramId = "_EndDelay1"
            value = "4900"
            unit = "ms"
            suppressRefresh = False
            Call Doc.SetStimulatorValue (outputIndex, paramId, value, unit, suppressRefresh)
            ' End SetStimulatorValue
            %}
        end
        function setSyncChan(obj,value)
            %
            %   Inputs
            %   ------
            %   value : string?
            %       - name of the channel????
            % unitless
            %
            %   TODO: What does this do?????
            parameter = '_MarkerChan';
            obj.sync_chan = labchart.stim_waveforms.value_and_unit(value, '');
            obj.h__SetStimulatorValue(parameter, obj.sync_chan);
        end
        
    end
    methods (Hidden)
        function h__SetStimulatorValue(obj, parameter, value_and_unit)
            %   calls SetStimulatorValue of the document class
            %
            %   Inputs:
            %   ---------
            %       -parameter: '_StartDelay' '_Baseline' ,etc...
            %       -value_and_unit: labchart.stim_waveforms.value_and_unit
            
            value = value_and_unit.value;
            unit = value_and_unit.unit;
            invoke(obj.h,'SetStimulatorValue',obj.chan, parameter , value, unit, obj.supress_refresh);
        end
    end
    
end

