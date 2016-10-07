classdef labchart
    %
    %   Class:
    %   labchart
    %
    %   Representatation of the Labchart Application
    
    properties
        h
    end
    
    properties (Dependent)
        active_document
        name %'ADInstruments LabChart Application'
        full_name %'C:\Program Files (x86)\ADInstruments\LabChart8\LabChart8.exe'
        visible
        busy
    end
    methods
        function value = get.active_document(obj)
            
            %Matlab error id when application was closed
            %MATLAB:COM:E0  => Labchart was closed
            
            temp = obj.h.ActiveDocument;
            if isempty(temp)
                value = [];
                return
            end
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
            if nargin == 1
                [file_name,path_name] = uigetfile('*.adicht','Select a file to open');
                
                if file_name == 0
                    opened_doc = [];
                    return
                end
                
                file_path = fullfile(path_name,file_name);
                
            end
            
            temp = obj.h.Open(file_path);
            opened_doc = labchart.document(temp,obj);
        end
    end
    
    methods
        function obj = labchart()
            %
            %    obj = labchart()
            %
            %    Returns an instance of the Labchart Application
            
            try
                %Let's reuse if possible, slightly faster
                obj.h = actxGetRunningServer('ADIChart.Application');
            catch ME
                %I'm not sure why we can't go into the application directly.
                %Trying to do so hangs the program. I found this example
                %in the automation example pdf (in the Matlab section)
                
                temp = actxserver('ADIChart.Document');
                obj.h = temp.Application;
                
                %Now we have the application reference, close
                %the unopened document
                temp.Close;
            end
        end
        function closeActiveDocument()
            obj.h.CloseActiveDocument();
        end
        function getConfigTabText(tab_name)
            
        end
        function delete(obj)
            %Do we need to do something here ....????
        end
    end
    
end

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

