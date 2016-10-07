classdef biphasic_pulse < handle
    %
    %   Class:
    %   labchart.stim_waveforms.biphasic_pulse
    
    properties (Hidden)
       h 
       chan %0 based
    end
    properties (Dependent)
        baseline
        start_delay
        n_pulses
        pulse_rate
        pulse_amplitude
        pulse_width
    end
    
    methods
        function set.baseline(obj,value)
            suppress_refresh = false;
            invoke(obj.h,'SetStimulatorValue',obj.chan,'_Baseline',value,'V',suppress_refresh);
        end
    end
    
    methods
        function obj = biphasic_pulse(h,chan)
            obj.h = h;
            obj.chan = chan;
        end
    end
    
end

