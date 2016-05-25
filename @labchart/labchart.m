classdef labchart
    %
    %   Class:
    %   labchart
    
    properties
       h 
    end
    
    properties (Dependent)
       active_document 
    end
    
    methods
        function value = get.active_document(obj)
           %TODO: Create static method for when this is NULL
           temp = obj.h.ActiveDocument;
           value = labchart.document(temp);
        end
    end
    
    methods
        function obj = labchart()
           %For some reason we hang when we do:
           %    ADIChart.Application
           %
           %    This creates a new document in the application
           %    and launches the application if it is not open
           temp = actxserver('ADIChart.Document');
           obj.h = temp.Application;
           
           %Now we have the application reference, close
           %the unopened document
           temp.Close;

           
        end
    end
    
end

