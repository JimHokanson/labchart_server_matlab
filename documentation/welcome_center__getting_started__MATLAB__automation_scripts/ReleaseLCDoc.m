function ReleaseLCDoc(doc)
%Disconnect any event handlers from doc and cleanly disconnect doc from the
%LabChart document it references.
if not(isempty(doc)) & doc.isinterface
    if not(isempty(doc.eventlisteners))
        doc.unregisterallevents
    end
    doc.release
end
