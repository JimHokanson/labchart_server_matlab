classdef callback_examples
    %
    %   Class:
    %   labchart.streaming.callback_examples
    
    properties
        Property1
    end
    
    methods (Static)
        function n_valid_samples(stream_obj,h_doc)
            %
            %   labchart.streaming.callback_examples.n_valid_samples
            %
            %   h_doc : labchart.document
            
            persistent h_tic
            
            %Output every 5 seconds
            if isempty(h_tic) || toc(h_tic) > 5
                h_tic = tic;
                fprintf('# of valid seconds in buffer = %0.2f\n',stream_obj.n_seconds_valid)
            end
        end
    end
end

