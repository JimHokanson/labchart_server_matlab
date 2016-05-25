function active = getActiveDocument()
%
%   active = labchart.getActiveDocument()
%
%   Outputs
%   -------
%   active : labchart.document

%TODO: Build in support for throwing an error when the document doesn't
%exist

temp = labchart;
active= temp.active_document;

end