classdef application
    %
    %   Class:
    %   labchart.application
    %
    %   Representatation of the Labchart Application
    %
    %   See Also
    %   --------
    %   labchart.openDocument
    %   labchart.getActiveDocument
    
    %{
    Other Labchart Server code on GitHub:
    https://github.com/rbute/BCIUI/blob/master/script/LabChartObject.m
    
    %}
    
    properties
        h
    end
    
    properties (Dependent)
        active_document
        name        %'ADInstruments LabChart Application'
        full_name   %Example: 'C:\Program Files (x86)\ADInstruments\LabChart8\LabChart8.exe'
        visible
        busy
    end
    methods
        function value = get.active_document(obj)
            
            %TODO:
            %Matlab error id when application was closed
            %MATLAB:COM:E0  => Labchart was closed
            %I think this means I just wanted to provide a more friendly
            %error message
            
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
    
    methods (Static)
        function running = checkIfRunning()
            %
            %   running = labchart.application.checkIfRunning()
            %
            %   This can be used to check if Labchart is running without
            %   actually causing Labchart to open in the process of
            %   checking.
            %
            %   Output
            %   ------
            %   running : logical
            %       True when an instance of Labchart is currently open.
                        
            p = System.Diagnostics.Process.GetProcessesByName('Labchart8');
            
            if p.Length == 0
                p = System.Diagnostics.Process.GetProcessesByName('Labchart7');
            end
            
            running = p.Length ~= 0;
        end
    end
    
    methods
        function opened_doc = open_document(obj,varargin)
           %obsolete ... 
           %TODO: Add warning ...
           opened_doc = openDocument(obj,varargin{:});
        end
        function opened_doc = openDocument(obj,file_path)
            %
            %   opened_doc = open_document(obj,file_path)
            %
            %   Output
            %   ------
            %   opened_doc : labchart.document
            
            %Obtain the file path
            %--------------------
            if nargin == 1
                [file_name,path_name] = uigetfile('*.adicht','Select a file to open');
                
                if file_name == 0
                    opened_doc = [];
                    return
                end
                
                file_path = fullfile(path_name,file_name);
            end
            
            %Call to open the file
            %---------------------
            temp = obj.h.Open(file_path);
            opened_doc = labchart.document(temp,obj);
        end
    end
    
    methods
        function obj = application()
            %
            %    obj = labchart.application()
            %
            %   This will open up LabChart if it is not already running.
            
            
            %This is where the magic begins ...
            %-----------------------------------
            try
                %Let's reuse if possible, slightly faster
                %This works if Labchart is running
                obj.h = actxGetRunningServer('ADIChart.Application');
                
                %         message: 'Error using actxGetRunningServer?The 
                %           server 'ADIChart.Application' is not 
                %           running on this system.'
                %      identifier: 'MATLAB:COM:norunningserver'
                %           stack: [0×1 struct]
                
                
            catch ME
                %I'm not sure why we can't go into the application directly.
                %Trying to do so hangs the program. I found this example
                %in the automation example pdf (in the Matlab section)
                
                %Note, this line launches 
                temp = actxserver('ADIChart.Document');
                
                obj.h = temp.Application;
                
                %Now we have the application reference, close
                %the unopened document
                temp.Close;
            end
        end
        function closeActiveDocument(obj)
            obj.h.CloseActiveDocument();
        end
        function getConfigTabText(tab_name)
            error('Not yet implemented')
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

