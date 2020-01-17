classdef butterworth_filter < handle
    %
    %   Class:
    %   labchart.streaming.processors.butterworth_filter
    
    properties
        b
        a
        state
    end
    
    methods
        function obj = butterworth_filter(order,cutoffs,fs,method)
            %
            %   obj =
            %   labchart.streaming.processors.butterworth_filter(order,cutoffs,fs,method)
            %
            %   Inputs
            %   ------
            %   method :
            %       'low'
            %       'high'
            %       'stop'
            %
            %
            %   Example
            %   -------
            %   obj = ...
            %   labchart.streaming.processors.butterworth_filter(2,5,1000,'low')
            
         [obj.b,obj.a] = butter(order,cutoffs/(fs/2),method);

        end
        function y = filter(obj,x,init)
           
            if init
                [y,obj.state] = filter(obj.b,obj.a,x);
            else
                [y,obj.state] = filter(obj.b,obj.a,x,obj.state);
            end
        end
        
% y = filter(b,a,x)
% y = filter(b,a,x,zi)
% y = filter(b,a,x,zi,dim)
% [y,zf] = filter(___)
    end
end

