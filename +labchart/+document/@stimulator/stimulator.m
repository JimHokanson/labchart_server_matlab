classdef stimulator < handle
    %
    %   Class:
    %   document.stimulator
    %
    %   Question:
    %   How do we know if we are connected to hardware to actually run
    %   this?
    %
    %   We typically have two channels available. We also have different
    %   parameters based on the type of pulse.
    %   We can also do custom where we string together a different set of
    %   pulses.
    %
    %   Refactoring:
    %   ------------
    %   stimulus_channel
    %       - 1 (and differential)
    %       - 2
    %       - differential
    %       - holds a stimulus waveform
    %   
    %   Panel - simplified 
    %   Dialog - more options ...
    
    %{
    doc = labchart.getActiveDocument();
    s = doc.stimulator();
    
    %}
    
    properties (Hidden)
        h
    end
    
    properties (Dependent)
        active_chan
    end
    methods
        function value = get.active_chan(obj)
            value = obj.real_active_chan + 1;
        end
        function set.active_chan(obj,value)
            if value == 1 || value == 2
                obj.real_active_chan = value - 1;
            else
                error('The active channel value must be 0 or 1')
            end
        end
    end
    
    properties (Hidden)
        real_active_chan
    end
    
    methods
        function obj = stimulator(h)
            obj.h = h;
            obj.real_active_chan = 0;
        end
        
        %How do these differ from enable stim????????
        function startStim(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   chan : 1 based (default: 'active_chan' property
            %       - 1, first output
            %       - 2, 2nd output
            %
            %   GHG: it seems that this is actually 0 based!!
            %        does not start stimulation, just sets the stimulator
            %        to the on position
            
            in.chan = obj.active_chan;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            invoke(obj.h,'SetStimulatorOn',in.chan,true);
        end
        function stopStim(obj,chan)
            %
            %   Input
            %   -----
            %   chan : 1 based
            %       - 1, first output
            %       - 2, 2nd output
            
            in.chan = obj.active_chan;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            invoke(obj.h,'SetStimulatorOn',in.chan,false);
        end
        function setDifferential(obj,chan,enable_flag)
            error('NOT YET IMPLEMENTED')
            obj.h.SetStimulatorDifferential()
        end
        function setStartMode(obj,mode)
            %
            %   Inputs
            %   ------
            %   mode : string
            %       - sampling - in this case, on means start stimulating
            %       - manually - this means that you need to explicitly
            %       - independently of sampling - so does this run
            %           when not sampling????
            %
            error('NOT YET IMPLEMENTED')
            obj.h.SetStimulatorStartMode();
        end
    end
    methods
        %????? - How do we know if these are legitimate values????
        %=> The right won't allow things out the "allowed range"
        %In the panel it shows a red exclamation point, but I don't think
        %I can query that
        function setRate(obj,freq,varargin)
            in.chan = obj.active_chan;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            suppress_refresh = false;
            chan_0b = in.chan-1; %0b => 0 based (instead of 1 based, which is what we are using)
            invoke(obj.h,'SetStimulatorValue',chan_0b,'_MaxRepeatRate',freq,'Hz',suppress_refresh);
        end
        function setAmplitude(obj,amplitude,varargin)
            in.chan = obj.active_chan;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            suppress_refresh = false;
            chan_0b = in.chan-1;
            invoke(obj.h,'SetStimulatorValue',chan_0b,'_PulseHeight1',amplitude,'V',suppress_refresh);
        end
        function setPulseWidth(obj,pulse_width,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   units :
            %       - 's'  - seconds
            %       - 'ms' - milliseconds
            %       - 'us' - microseconds
            %   chan :
            
            in.units = 'us';
            in.chan = obj.active_chan;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            suppress_refresh = false;
            invoke(obj.h,'SetStimulatorValue',in.chan,'_PulseWidth1',pulse_width,in.units,suppress_refresh);
        end
        function setPulseWidthSlider(obj)
            %How can we make this more generic???????
            %Minimum is 50 us
            in.units = 'us';
        end
        
    end
    
    methods
        function setBaseline(obj,value,varargin)
            in.chan = obj.active_chan;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            suppress_refresh = false;
            invoke(obj.h,'SetStimulatorValue',in.chan,'_Baseline',value,'V',suppress_refresh);
        end
        function setStartDelay(obj,value,varargin)
            in.chan = obj.active_chan;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            suppress_refresh = false;
            invoke(obj.h,'SetStimulatorValue',in.chan,'_StartDelay',value,'s',suppress_refresh);
        end
        function setRepeats(obj,n_repeats,varargin)
            %
            %   Input
            %   -----
            %   n_repeats :
            %       - A value of -1 means infinite
            
            in.chan = obj.active_chan;
            in = labchart.sl.in.processVarargin(in,varargin);
            
            suppress_refresh = false;
            invoke(obj.h,'SetStimulatorValue',in.chan,'_StartDelay',n_repeats,'',suppress_refresh);
        end
    end
    methods
        
        
    end
end


%{
OpenStimulatorDialog
OpenStimulatorPanel
SetOutputEnabled_Independent
- what does this mean? - why does an output need to be enabled?
- This is explicitly different then turning it on
- or does this "enabled" mean "on" and this "on" mean "stimulate"
- yes, in the GUI, the buttons on and off correspond to enable and disable
-
SetStimulatorIsolated - select between isolated and analogue outputs
DONE - SetStimulatorOn
SetStimulatorOutputRangeIndex????
SetStimulatorStartMode
    

%}


%
%outputIndex = 0
%paramID = "_PulseHeight1"
%
%"_Amplitude"
%"_PulseWidth"
%"_MaxRepeatRate"
%etc
%value = "1"
%unit = "V"
%suppressRefresh = False
%Doc.SetStimulatorValue(outputIndex,paramId,value,unit,supressRefresh)
