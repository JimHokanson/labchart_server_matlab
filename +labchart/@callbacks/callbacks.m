classdef callbacks
    %
    %   Class:
    %   labchart.callbacks
    %
    %   This class is meant to contain example callbacks that can be used
    %   as examples or as actual callbacks for projects


    methods (Static)
        function newData(varargin)
            %
            %   fh = @labchart.callbacks.newData
            %
            %   Example
            %   -------
            %   d = labchart.getActiveDocument()
            %   fh = @labchart.callbacks.newData;
            %   d.registerOnNewSamplesCallback(fh);
            %
            %   d.unregisterAllEvents

            fprintf('%d new samples collected\n',varargin{4}.newTicks);
        end
        function newDataStreamingExample1(doc,stream,varargin)
            %
            %
            %
            %   Examples
            %   --------
            %   1) 
            %   d = labchart.getActiveDocument();
            %   name = 'void volume low pass ';
            %   fs = 1000;
            %   n_seconds_valid = 10;
            %   s1 = labchart.streaming.streamed_data1(fs,n_seconds_valid,name,...
            %       'h_axes',gca,'plot_options',{'Color','r'});
            %   fh = @(varargin)labchart.callbacks.newDataStreamingExample1(d,s1,varargin{:});
            %   d.registerOnNewSamplesCallback(fh);
            %
            %   2) Adding a filter to the new data
            %   ----------------------------------------------
            %   d = labchart.getActiveDocument();
            %   name = 'void volume low pass ';
            %   fs = 1000;
            %   n_seconds_valid = 10;
            %   %Low pass filter the incoming data ...
            %   bf = labchart.streaming.processors.butterworth_filter(2,0.2,fs,'low');
            %   s1 = labchart.streaming.streamed_data1(fs,n_seconds_valid,name,...
            %       'h_axes',gca,'plot_options',{'Color','r'});
            %   %This is another way to toggle arguments ....
            %   % i.e. after creation and before running
            %   %Note we pass in the 
            %   s1.new_data_processor = @bf.filter;
            %   fh = @(varargin)labchart.callbacks.newDataStreamingExample1(d,s1,varargin{:});
            %   d.registerOnNewSamplesCallback(fh);
            
            %TODO: We could try a callback that only calls addData
            %if the # we get from one of the arguments indicates that
            %we actually have samples ...
            
            stream.addData(doc)
            
        end
        function dispBlockStarted(varargin)
            %
            %   fh = @labchart.callbacks.dispBlockStarted
            %
            %   Example
            %   -------
            %   d = labchart.getActiveDocument()
            %   fh = @labchart.callbacks.dispBlockStarted;
            %   d.registerBlockStartCallback(fh);
            disp('Block starting - labchart.callbacks.dispBlockStarted')
        end
        function dispBlockEnded(varargin)
            %
            %   fh = @labchart.callbacks.dispBlockEnded
            %
            %   Example
            %   -------
            %   d = labchart.getActiveDocument()
            %   fh = @labchart.callbacks.dispBlockEnded;
            %   d.registerBlockEndCallback(fh);
            
            disp('Block ended - labchart.callbacks.dispBlockEnded')
        end
     	function dispBlockStartedWithNumber(doc,varargin)
            %   fh = @labchart.callbacks.dispBlockStartedWithNumber
            %
            %   Example
            %   -------
            %   d = labchart.getActiveDocument()
            %   %NOTE: the 4 ~ are for ignoring the normal inputs
            %   fh = @(varargin)labchart.callbacks.dispBlockStartedWithNumber(d,varargin{:});
            %   d.registerBlockStartCallback(fh);
            
            %Number of records hasn't yet incremented ...
            fprintf('Block %d starting - labchart.callbacks.dispBlockStartedWithNumber\n',doc.number_of_records+1)
        end
        function dispBlockEndedWithNumber(doc,varargin)
            %   fh = @labchart.callbacks.dispBlockEndedWithNumber
            %
            %   Example
            %   -------
            %   d = labchart.getActiveDocument()
            %   %NOTE: the 4 ~ are for ignoring the normal inputs
            %   fh = @(varargin)labchart.callbacks.dispBlockEndedWithNumber(d,varargin{:});
            %   d.registerBlockEndCallback(fh);
            
            fprintf('Block %d ended - labchart.callbacks.dispBlockEndedWithNumber\n',doc.number_of_records)
        end
    end
end

