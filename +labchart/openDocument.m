function doc = openDocument(file_path)
%x Opens a Labchart document
%
%   doc = labchart.openDocument(file_path)
%
%   TODO: Implement this:
%   https://forum.adinstruments.com/viewtopic.php?f=7&t=782&p=2270#p2270

app = labchart.application;
active_doc = app.active_document;
if ~isempty(active_doc)
    if strcmp(active_doc.file_path,file_path)
        doc = active_doc;
        return
    end
end

doc = app.open_document(file_path);

end