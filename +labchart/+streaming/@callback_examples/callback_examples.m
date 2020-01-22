classdef callback_examples
    %
    %   Class:
    %   labchart.streaming.callback_examples
    
    properties
        Property1
    end
    
    methods (Static)
        function nValidSamples(stream_obj,h_doc)
            %
            %   labchart.streaming.callback_examples.nValidSamples
            %
            %   h_doc : labchart.document
            
            persistent h_tic
            
            %Output every 5 seconds
            if isempty(h_tic) || toc(h_tic) > 5
                h_tic = tic;
                fprintf('# of valid seconds in buffer = %0.2f\n',stream_obj.n_seconds_valid)
            end
        end
        function averageSamplesAddComment(stream_obj,h_doc)
         	persistent h_tic
            
            %Output every 5 seconds
            if isempty(h_tic) 
                h_tic = tic;
            else
                if toc(h_tic) > 5
                    h_tic = tic;
                    [data,time] = stream_obj.getData();
                    if length(data) ~= length(time)
                        fprintf(2,'WTF Jim!!! %d,%d\n',length(data),length(time))
                    end
                    h_doc.addComment(sprintf('Mean %g starting at %g',mean(data),time(1)));
                end
            end
        end
    end
end

