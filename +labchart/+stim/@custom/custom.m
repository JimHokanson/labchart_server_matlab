classdef custom
    %
    %   Class:
    %   labchart.stim.custom
    
    %{
    
    ' Begin SetStimulatorValue
	outputIndex = 0
	paramId = "_Delay6"
	value = "0"
	unit = "s"
	suppressRefresh = False
	Call Doc.SetStimulatorValue (outputIndex, paramId, value, unit, suppressRefresh)
	' End SetStimulatorValue
	
	' Begin SetStimulatorValue
	outputIndex = 0
	paramId = "_Delay6"
	value = "2"
	unit = "s"
	suppressRefresh = False
	Call Doc.SetStimulatorValue (outputIndex, paramId, value, unit, suppressRefresh)
	' End SetStimulatorValue
	
	' Begin SetStimulatorValueOptions
	outputIndex = 0
	paramId = "_PulseWidth5"
	minimum = 50
	maximum = 1000
	normalIncrement = 4.75e-007
	useLogSlider = True
	useSteps = True
	unit = "us"
	Call Doc.SetStimulatorValueOptions (outputIndex, paramId, minimum, maximum, normalIncrement, useLogSlider, useSteps, unit)
	' End SetStimulatorValueOptions
	
	' Begin SetStimulatorValue
	outputIndex = 0
	paramId = "_PulseWidth5"
	value = "100"
	unit = "us"
	suppressRefresh = False
	Call Doc.SetStimulatorValue (outputIndex, paramId, value, unit, suppressRefresh)
	' End SetStimulatorValue

    
    
    
    %}
    
    
    properties
    end
    
    methods
    end
    
end

