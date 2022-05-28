function RegisterLCEvents(doc)
%Hooks up the callback functions in LCCallBacks.m to the events generated
%by the LabChart document. These callbacks use global variables to share
%state.
global gLCDoc;
global gChans;

%Disconnect any existing event handlers
if not(isempty(gLCDoc)) & gLCDoc.isinterface & not(isempty(gLCDoc.eventlisteners))
    gLCDoc.unregisterallevents;
end

gLCDoc = doc;

gLCDoc.registerevent({
    'OnStartSamplingBlock' LCCallBacks('OnBlockStart'); 
    'OnNewSamples' LCCallBacks('OnNewSamples');
    'OnFinishSamplingBlock' LCCallBacks('OnBlockFinish')
    'OnSelectionChange' LCCallBacks('OnSelectionChange')
    })

