classdef fake_streaming_doc
    %
    %
    %   Not yet implemented. The goal is to support the basic functionality
    %   needed to pretend to stream new data (for testing purposes).
    %
    %   Things needed:
    %   - current record
    %   - register events
    %   - get data ...
    
    properties
        current_record = 1 %This can be read or written to.
        ticks_per_second = 20000
    end
    
    methods
        function obj = fake_streaming_doc()
        end
        function output = getSecondsPerTick(current_record)
            output = 1/obj.ticks_per_second;
        end
    end
end

