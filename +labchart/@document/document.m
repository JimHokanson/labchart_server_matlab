classdef document
    %
    %   Class:
    %   labchart.document
    
    properties (Hidden)
        h
    end
    
    properties (Dependent)
        
        d0 = '-------  Status  -------'
        current_record
        is_sampling
        is_record_mode %??? 
        %TODO: Add more documentation on what this is
        %       "whether in record mode (even if not sampling) rather tha monitor mode"
        %This seems like monitor mode might indicate when it can't connect
        %with the hardware
        
        d1 = '-------  Channels --------'
        number_of_channels
        number_of_displayed_channels
        number_of_records
        
        d2 = '-------- File Information -------'
        name
        file_path
        root_path
        %saved - true if document hasn't changed since last being saved
        
    end
    
    %{
'Application'
'Parent'
DONE 'Name' => name
DONE 'FullName' => file_path
DONE 'Path' => root_path
'Saved'
DONE 'NumberOfRecords'
DONE 'NumberOfChannels'
'SelectionStartRecord'
'SelectionStartOffset'
'SelectionEndRecord'
'SelectionEndOffset'
'SelectionObject'
NYI 'Macros'
NYI 'Services'
DONE 'IsSampling' => is_sampling
DONE 'IsRecordMode' => is_record_mode
DONE 'SamplingRecord' => current_record
DONE 'NumberOfDisplayedChannels'
    
    %}
    
    methods
        function value = get.current_record(obj)
           value = obj.h.SamplingRecord;
           %-1 is for not sampling
           %otherwise shift from 0 to 1 based
           if value ~= -1
               value = value + 1;
           end
        end
        function value = get.is_sampling(obj)
           value = obj.h.IsSampling; 
        end
        function value = get.is_record_mode(obj)
           value = obj.h.IsRecordMode;
        end
        function value = get.number_of_channels(obj)
           value = obj.h.NumberOfChannels;
        end
        function value = get.number_of_displayed_channels(obj)
           value = obj.h.NumberOfDisplayedChannels;
        end
        function value = get.number_of_records(obj)
           value = obj.h.NumberOfRecords;
        end
        function value = get.name(obj)
           value = obj.h.Name; 
        end
        function value = get.file_path(obj)
           value = obj.h.FullName;
        end
        function value = get.root_path(obj)
           value = obj.h.Path;
        end
    end
    
    methods
        function obj = document(h)
           obj.h = h; 
        end
    end
    
    methods
        function addComment(obj,str,channel)
            %
            %   addComment(obj,str, *channel)
            %
            %   Inputs
            %   -------
            %   channel : (default -1)
            %       -1 applies the comment to all channels
            %   	#s are 1 based
            %   
            %   Examples
            %   --------
            %   active = labchart.getActiveDocument();
            %   active.addComment('Adding comment to channel 1',1);
            
            if ~exist('channel','var') || isempty(channel)
               channel = -1; 
            end
            
            %Transition from 1 based here to 0 based in the code
            if channel ~= -1;
                channel = channel - 1;
            end
            
           obj.h.AppendComment(str,channel) 
        end
        function startSampling(obj,varargin)
            %
            %   startSampling(obj)
            %
            %   Examples
            %   --------
            %   %Start sampling for an indefinite period and return 
            %   %immediately
            %   active = labchart.getActiveDocument();
            %   active.startSampling();
            
            %Status: Haven't tested all values of inputs
            
            
            in.time = 0; %0 means sample indefinitely
            in.block_until_done = false;
            in.sample_stop_mode = 0;
            in = labchart.sl.in.processVarargin(in,varargin);
            %0 - period
            %1 - stop sampling after trigger
            %2 - user stop
            %time in seconds
            %wait for sampling 
           
            obj.h.StartSampling(in.time,in.block_until_done,in.sample_stop_mode);
        end
        function stopSampling(obj)
            obj.h.StopSampling();
        end
        
    end
end

%{

%====  Properties ======

'Application'
'Parent'
'Name'
'FullName'
'Path'
'Saved'
'NumberOfRecords'
'NumberOfChannels'
'SelectionStartRecord'
'SelectionStartOffset'
'SelectionEndRecord'
'SelectionEndOffset'
'SelectionObject'
'Macros'
'Services'
'IsSampling'
'IsRecordMode'
'SamplingRecord'
'NumberOfDisplayedChannels'

%==== Methods =====

Activate                  
AddCommentAtSelection     
AddToDataPad              
AppendComment             
AppendFile                
AppendFileEx              
Close                     
CreatePlot                
GetChannelData            
GetChannelName            
GetDataPadColumnChannel   
GetDataPadColumnFuncName  
GetDataPadColumnUnit      
GetDataPadCurrentValue    
GetDataPadValue           
GetDigitalInputBit        
GetDigitalInputState      
GetDigitalOutputBit       
GetDigitalOutputState     
GetName                   
GetPlot                   
GetPlotId                 
GetRecordLength           
GetRecordSecsPerTick      
GetRecordStartDate        
GetScopeChannelData       
GetSelectedData           
GetSelectedValue          
GetUnits                  
GetViewPos                
ImportMacros              
IsChannelSelected         
MatLabPutChannelData      
MatLabPutFullMatrix       
PlayMacro                 
PlayMessage               
Print                     
RecordTimeToTickPosition  
ResetSelection            
Save                      
SaveAs                    
SaveChartViewAsImage      
SelectChannel             
SelectRecord              
SetAnalogOutputValue      
SetArithChanCalc          
SetChannelName            
SetDevice                 
SetDigitalOutputBit       
SetDigitalOutputState     
SetSelectionRange         
SetSelectionTime          
DONE StartSampling             
StopSampling              
TickPositionToRecordTime  
WaitWhileSampling         
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
