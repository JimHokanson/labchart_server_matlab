function ClearLC()
%Clear global variables used to reference the LabChart Application and
%Document objects. 
%This is particularly useful when trying to re-establish communication with
%LabChart after LabChart has been closed while MATLAB still holds
%references to it. Fixes the "Error: The RPC server is unavailable." error.
global gLCApp;
global gLCDoc;
ReleaseLC;
clear gLCDoc;
clear gLCApp;
