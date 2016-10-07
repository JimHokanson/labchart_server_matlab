classdef comments
    %
    %   Class:
    %   labchart.document.comments
    %
    
    properties (Hidden)
        h
    end
    
    methods
        function obj = comments(h)
            
        end
        function addCommentAtEnd(obj)
        end
        function addCommentAtInsertionPoint(obj)
            
        end
        function addCommentAtPosition(obj)
            
        end
        function clearAllPresetComments(obj)
            obj.h.ClearAllPresetComments();
        end
        function configurePresetComment(obj)
            %This is really complicated
            %
            %   Event
            
            %See documentation in Macro editor
            
            error('Not yet implemented')
            
            obj.h.ConfigurePresetComment(event,comment,channel);
        end
        function deleteComments(obj)
            
        end
        function openAddCommentDialog(obj)
            
        end
        function replacePresetComment(obj)
            
        end
        function selectComment(obj)
            
        end
        function setCommentText(obj)
        end
        function setCommentsViewFilterText(obj)
            
        end
        function showComment(obj)
        end
        function showCommentAdvanced(obj)
        end
        function showCommentsViewDates(obj)
            
        end
        function showCommentsViewTimes(obj)
            
        end
    end
    
end

%Closing the Comments Preset Window:
%all Doc.OpenCloseWindow ("{8EC8BD85-CBC1-42DF-A8CF-85021979A2CE}-1", 0, False)


