function doc = openDocument(file_path)
%x Opens a Labchart document
%
%   doc = labchart.openDocument(file_path)
%
%   Inputs
%   ------
%   file_path : string
%       Path of the file to open.
%
%   Outputs
%   -------
%   doc : labchart.document

app = labchart.application;
active_doc = app.active_document;
if ~isempty(active_doc)
    if strcmp(active_doc.file_path,file_path)
        doc = active_doc;
        return
    end
end

doc = app.openDocument(file_path);

end