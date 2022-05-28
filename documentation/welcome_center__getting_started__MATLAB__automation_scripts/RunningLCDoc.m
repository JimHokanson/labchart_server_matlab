function d = RunningLCDoc()
%Access the running LabChart Application object and return a reference to the LabChart
%document that currently has focus.
global gLCApp;
if isempty(gLCApp)
    gLCApp = actxGetRunningServer('ADIChart.Application');
end
d = gLCApp.ActiveDocument;
if not(isempty(d))
    d.Name  %display the document's name
end
