classdef value_and_unit
    %   labchart.stim_waveforms.value_and_unit
    %stores a value and a unit for parameters of stimulation
    
    properties
        value
        unit
    end
    
    methods
        function obj = value_and_unit(value, unit)
           obj.value = value;
           obj.unit = unit;
        end
    end
    
end

