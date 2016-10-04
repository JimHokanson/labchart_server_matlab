classdef labchart
    %
    %   Class:
    %   labchart
    
    properties
       h 
    end
    
    properties (Dependent)
        active_document 
        name
        full_name
        visible
        busy
    end
    
    methods
        function value = get.active_document(obj)
           %TODO: Create static method for when this is NULL
           temp = obj.h.ActiveDocument;
           value = labchart.document(temp,obj);
        end
        function value = get.name(obj)
           value = obj.h.Name; 
        end
        function value = get.full_name(obj)
           value = obj.h.FullName; 
        end
        function value = get.visible(obj)
           value = obj.h.Visible; 
        end
        function value = get.busy(obj)
           value = obj.h.Busy; 
        end
    end
    
    methods
        function opened_doc = open_document(obj,file_path)
            temp = obj.h.Open(file_path);
            opened_doc = labchart.document(temp,obj);
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
        function delete(obj)
           %Do we need to do something here ....???? 
        end
    end
    
end

%{

    'Name'
    'FullName'
    'Parent'
    'ActiveDocument'
    'Application'
    'Visible'
    'Busy'
    'GettingStartedFolder'
    'MyDataFolder'
    'MyWelcomeCenterFolder'
    'AppExeFolder'

    'CloseActiveDocument'
    'GetConfigTabText'
    'Open'
    'Quit'
    'ShowHtmlFrame'
    'addproperty'
    'delete'
    'deleteproperty'
    'events'
    'get'
    'invoke'
    'loadobj'
    'release'
    'saveobj'
    'set'


%}

