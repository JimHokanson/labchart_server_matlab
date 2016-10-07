function doc = openDocument(file_path)
%x Opens a Labchart document
%
%   doc = labchart.openDocument(file_path)
%
%   This will open another instance even if the document is already opened.

app = labchart;
active_doc = app.active_document;
if ~isempty(active_doc)
    if strcmp(active_doc.file_path,file_path)
        doc = active_doc;
        return
    end
end
doc = app.open_document(file_path);

end