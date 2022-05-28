function doc = NewLCDoc()
%Create a new empty document and set the gLCApp global to reference the
%LabChart Application object.
global gLCApp;

doc = actxserver('ADIChart.Document');
gLCApp = doc.Application;
doc.Name;  %poke the document to make it visible in LabChart 
