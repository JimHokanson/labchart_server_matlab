function ReleaseLC()
%Disconnect from the LabChart document and LabChart application objects.
global gLCApp;
global gLCDoc;
ReleaseLCDoc(gLCDoc);
if not(isempty(gLCApp)) & gLCApp.isinterface
    gLCApp.release;
end
