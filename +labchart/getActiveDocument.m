function active = getActiveDocument()
%x Retrieve the currently active document in Matlab
%
%   active = labchart.getActiveDocument()
%
%   Outputs
%   -------
%   active : labchart.document
%       If no document is currently open, this code will throw an error.
%

temp = labchart.application;
active = temp.active_document;

if isempty(active)
   error('labchart:getActiveDocument','No active document found'); 
end

end