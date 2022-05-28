function doc = OpenLCDoc(path)
%Start LabChart if needed, open the file specified by path, and return a
%reference to that LabChart document.
global gLCApp;
GetLCApp;
doc = gLCApp.Open(path);