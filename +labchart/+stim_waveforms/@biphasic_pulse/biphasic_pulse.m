classdef biphasic_pulse < handle
    %
    %   Class:
    %   labchart.stim_waveforms.biphasic_pulse
    %
    %
    %
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
        baseline     % Baseline
        start_delay  % Start Delay
        
        n_pulses     % Repeats % if -1, set to infinit repeats. Otherwise, it is a string with the number of repeats
        pulse_rate   % Max Repeat Rate (displayed/chosen in seconds...)
        pulse_amplitude %Pulse Height
        pulse_width % Pulse Width
        sync_chan %Marker Channel
        
        
        supress_refresh
    end
    methods
        function obj = biphasic_pulse(h,chan)
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
        function setNPulses(obj,value)
            % unitless
            % a value of '-1' indicates infinite repeats
            unit = '';
            obj.n_pulses = labchart.stim_waveforms.value_and_unit(value, unit);
            parameter = '_WaveformRepeat';
            obj.h__SetStimulatorValue(parameter, obj.n_pulses);
        end
        function setPulseRate(obj,value, unit)
            allowed_units = {'s', '\min', 'Hz'};
            if ~ismember(unit, allowed_units)
                error('input unit is not allowed')
            end
            
            obj.pulse_rate = labchart.stim_waveforms.value_and_unit(value, unit);
            
            parameter = '_MaxRepeatRate';
            obj.h__SetStimulatorValue(parameter, obj.pulse_rate);
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
        function setSyncChan(obj,value)
            % unitless
            parameter = '_MarkerChan';
            obj.sync_chan =labchart.stim_waveforms.value_and_unit(value, '');
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

