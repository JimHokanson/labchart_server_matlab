classdef services
    %
    %   Class:
    %   labchart.services
    %
    %   Get this from the Document   
    
    properties (Hidden)
        h
    end
    
    methods
        function obj = services(h)
           obj.h = h; 
        end
    end
    
end

%{
    'Breakpoint' (message_string,[has_stop_button (True)]
    => I'm not sure what stopping would mean ...

    'DeregisterScriptEvents'
    'EndProgress'
    'IsPlayingMacro'
    'PlayBeep'
    (freq - 37 to 32767, duration_ms) (both as long)

    'RegisterScriptEvent'
    'ShouldExitCurrentRepeat'
    'ShowProgressInPlayer'
    'Sleep'
    'StopMacroExecution'


%}