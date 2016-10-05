classdef labchart
    %
    %   Class:
    %   labchart
    
    %{
    CloseActiveDocument  
GetConfigTabText     
Open                 
Quit                 
ShowHtmlFrame        
addproperty          
delete               
deleteproperty       
events               
get                  
invoke               
loadobj              
release              
saveobj              
set   
    %}
    
    
    %{
    RegisterLCEvents(gLCApp.ActiveDocument)
    
    %}
    
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
    
    %}
    
    properties
       h 
    end
    
    properties (Dependent)
       active_document %labchart.document OR []
       my_data_folder
       name
    end
    
    methods
        function value = get.active_document(obj)
           %TODO: Create static method for when this is NULL
           
           %MATLAB:COM:E0  => Labchart was closed
           
           temp = obj.h.ActiveDocument;
           if isempty(temp)
               value = temp;
           else
               value = labchart.document(temp);
           end
        end
        function value = get.my_data_folder(obj)
           value = obj.h.MyDataFolder;
        end
        function value = get.name(obj)
           value = obj.h.Name; 
        end
    end
    
    methods
        function obj = labchart()
           %For some reason we hang when we do:
           %    ADIChart.Application
           %
           %    This launches the application if it is not open.
           
           %We could also use:
           %actxGetRunningServer('ADIChart.Application')
           
           temp = actxserver('ADIChart.Document');
           obj.h = temp.Application;
           
           %Now we have the application reference, close
           %the unopened document
           temp.Close;
        end
        function closeActiveDocument()
            
        end
        function getConfigTabText(tab_name)
           
        end
        function doc = open(obj,file_path)
            %??? What are the flags????
            
            %{
            file_path = 'C:/test.adicht';
            lc.open(file_path);
            lc.open('missing')
            %}
            
            %Wrong path throws a prompt in Labchart that is blocking
            %Don't screw this up!
            
            if ~exist(file_path,'file')
                error('Requested file does not exist')
            end
            
            flags = 0;
            temp = obj.h.Open(file_path,flags);
            doc = labchart.document(temp);
            
        end
        function quit(obj,discard_unsaved_docs)
            %
            %   Inputs
            %   ------
            %   discard_unsaved_docs : logical
           obj.h.Quit(discard_unsaved_docs) 
        end
        %function showHtmlFrame() %NYI
    end
    
end

