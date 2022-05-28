function app = GetLCApp;
%Start LabChart, if needed, and return a reference to the LabChart
%Application object.
global gLCApp; % only one instance of LabChart can run at a time
if isempty(gLCApp) | not(gLCApp.isinterface)
    % create a new document to get LabChart running!
    doc = actxserver('ADIChart.Document');
    gLCApp = doc.Application;   
    doc.Close();
end
app = gLCApp;
