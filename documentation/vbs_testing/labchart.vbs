' LabChart External Events.vbs
' Created for LabChart 8.0.3
' 31/3/2014
'
' This script shows how to consume the COM events that LabChart sends. Includes handlers
' for all currently supported events.
'
' - found at: https://github.com/rbute/BCIUI/blob/master/script/Export%20As%20MATLAB/LabChart%20External%20Events.vbs
' - might have originally shipped with LabChart

WScript.Echo "WTF Batman2"

Set doc2 = CreateObject("ADIChart.Document") ' Create a new document. LabChart will launch if not already open.
'Set doc = GetObject("C:\MyFile.adicht") ' Or load an existing file

Set app = doc2.Application

doc2.Close()

'need to wait for that doc to actually close, so our active doc is now active again
WScript.Sleep 1000

Set doc = app.ActiveDocument

WScript.Echo doc.Name

WScript.Echo "WTF Batman"

' Allows us to trap COM events that are fired fom LabChart.
Call WScript.ConnectObject (doc, "lc_")

' Now set up appropriate handlers to events we care about.
'
' For external scripts, all event handlers are prefixed with "lc_" because this is what
' we supplied when we called WScript.ConnectObject()

' RegisterScriptEvent is important here as it tells LabChart that someone cares about
' the digital IO stream.
' Call doc.Services.RegisterScriptEvent (2, "Digital Input Advanced", "")

' NewValue: 8-bit value representing the current state of the digital input.
' OldValue: 8-bit value representing the previous state of the digital input.
' Position: The index (starting from 0) of the sample at which the change occurred.
Sub lc_OnDigitalInputChangedAdvanced (NewValue, OldValue, Position)
	' Add your code for handling this event here..
End Sub

' RegisterScriptEvent is important here so that we can tell LabChart which channel
' we are interested in.
'Call doc.Services.RegisterScriptEvent (3, "ch2", "")
Sub lc_OnGuidelineCrossed (ChannelNumber, GuidelineNumber, IsRising, Position, GuidelineValue, SignalValue)
	' Add your code for handling this event here..
End Sub

Call doc.Services.RegisterScriptEvent (4, "Key Pressed", "")
Sub lc_OnKeysPressed (Key, IsControlDown, IsShiftDown)
	' Add your code for handling this event here..
End Sub

' RegisterScriptEvent is important here as it tells LabChart which event data channel
' we are interested in.
' This example is commented out because it will require a Cyclic Measurements channel
' calculation to be already set up on Channel 1.
' Call doc.Services.RegisterScriptEvent (1, "ch1", "")

' This is called when an event arrives into a specified channel.
'
' ChannelNumber: Number of the channel (starting from 1) that contains the events.
' IsInternalDetectorChannel: If True, the ChannelNumber parameter refers to a "hidden"
'	channel that certain Add-Ons create to perform their event detection (such as Cyclic
'	Measurements). If False, ChannelNumber is a regular, visible channel.
' EventValue: The event's value.
' SampleAtEvent: The index of the sample where the event occurred.
Sub lc_OnEventDataArrived (ChannelNumber, IsInternalDetectorChannel, EventValue, SampleAtEvent)
    ' Add your code for handling this event here..
End Sub

Sub lc_OnCommentAdded (text, channel, recordIndex, position)
	' Add your code for handling this event here..
	Wscript.Echo "Like this?"
End Sub

Sub lc_OnDataPadSelectionChanged (Sheet, Column, Row, Width, Height)
	' Add your code for handling this event here..
End Sub

' Called when the user starts sampling in LabChart.
Sub lc_OnStartSampling
	' Add your code for handling this event here..
End Sub

' Called each time a new block is started (i.e. with repeated triggering).
Sub lc_OnStartSamplingBlock
	' Add your code for handling this event here..
End Sub

' Called each time samples arrive into LabChart. This is called roughly 20 times each second.
Sub lc_OnNewSamples
	' Add your code for handling this event here..
End Sub

' Called when a block ends.
Sub lc_OnFinishSamplingBlock
	' Add your code for handling this event here..
End Sub

' Called when the users stops sampling.
Sub lc_OnFinishSampling
	' Add your code for handling this event here..
End Sub

' Called each time the LabChart selection changes.
Sub lc_OnSelectionChange
	' Add your code for handling this event here..
End Sub

'Call Doc.SetStimulatorOn (0, True)
'Call Doc.StartSampling (10, False)

' This loop keeps the script running indefinitely. If the script were to terminate now
' we'd never receive any events!

Do
	WScript.Sleep 10
Loop While True

' As events are registered, LabChart maintains certain state required for the events
' to be fired correctly. Calling deregister clears this stuff out so as not to impact
' LabChart performance.
Call doc.Services.DeregisterScriptEvents()
