classdef record
    %
    %   Class:
    %   labchart.record
    %
    %   This is meant to provide data retrieval of calculated channels.
    %   It is not yet complete.
    %   https://forum.adinstruments.com/viewtopic.php?f=7&t=771
    
    %{
    temp = labchart;
    doc = labchart.getActiveDocument;
    rec = doc.getRecord(3);
    %}
    
    properties
        h
    end
    
    properties
        id
    end
    
    properties (Hidden)
        lc_id
    end
    
    properties (Dependent)
        n_ticks
        fs
        record_length %seconds
        %start_date %NYI
    end
    methods
        function value = get.n_ticks(obj)
            value = obj.h.GetRecordLength(obj.lc_id);
        end
        function value = get.fs(obj)
            value = 1/obj.h.GetRecordSecsPerTick(obj.lc_id);
        end
        function value = get.record_length(obj)
            value = obj.n_ticks/obj.fs;
        end
    end
    
    methods
        function obj = record(h,record_id)
            obj.h = h;
            obj.id = record_id;
            obj.lc_id = record_id+1;
        end
        %GetUnits(int,int) - channel number, block number
        
        
        %This is implemented in the document class
%         function data = getChannelData(obj,name_or_index,block_id,varargin)
%             
%             %TODO: Push this down to an instantiated channel object
%             %
%             in.start_sample = 1;
%             in.end_sample = [];
%             in.n_samples = 'all';
%             in = sl.in.processVarargin(in,varargin);
%             
%             %flags, chan #, block#, start_sample, num_samples
%             %flags 
%             %   - 1, doubles
%             %   - 0, variant
%             %chan # - 1 based
%             %block # - 0 based????
%             %start_sample
%             
%             %TickPositionToRecordTime
%             %
%             
%             %??? What happens for an invalid channel # => single NaN value
%             %
%             %Too many samples requested - just returns what it has
%             flags = 0;
%             chan_number = 1;
%             block_number = 6; %1 based
%             start_sample = 1;
%             n_samples = 10*60*1000;
%             
%             %This is returned upsampled as well :/
%             data = obj.h.GetChannelData(flags,chan_number,block_number,start_sample,n_samples);
%             
%             %Time based
%             
%             keyboard;
%             
%             %This function returns the data after upsampling :/
%             %data = obj.h.GetSelectedData(1,1);
%             
%             %obj.h.SetSelectionTime(5,0,5,120)
%         end
    end
    
end

