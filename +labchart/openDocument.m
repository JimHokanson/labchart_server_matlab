function doc = openDocument(file_path)
%x Opens a Labchart document
%
%   doc = labchart.openDocument(file_path)
%
%   This will open another instance even if the document is already opened.

app = labchart;
doc = app.open_document(file_path);

end