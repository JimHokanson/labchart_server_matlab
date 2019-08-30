classdef comments
    %
    %   Class:
    %   labchart.document.comments
    %
    %   JAH 08/2019 => This class is a work in progress
    %
    %
    %   Move Comment - no listener in the macro recording
    
    
    %   ?How to get comments from running Labchart instance?
    %   - select
    %   - Doc.copy("Comments View")
    %    
    
    properties (Hidden)
        h
    end
    
    methods
        function obj = comments(h)
            obj.h = h;
        end
        function str = getCommentInfo(obj,index_1b)
            %
            %   A work in progress
            %
            %   ??? I can't figure out how to control the time mode
            %   so that we get seconds from the start of the block
            %
            %       - this turns out not to be an issue since
            %       we can 
            %
            %   ??? I can't figure out how to resolve which block
            %   the comments belong to ...
            %
            %
            %   ???? How many comments - a deleted comment shows up
            %   as empty, so we need to keep going in case we just
            %   requested a deleted comment, not just a non-existant
            %   comment (yet to be created)
            
            %record start date is available, so if we did absolute
            %time we could 
            
            %I think this may only work if the user doesn't click on
            %anything while it is running :/
            %
            %It just seems not to work if the comments view is visible -
            %wtf :/
            %
            %   Overall it seems buggy ...
            %
            %   In another case this only 
            
           obj.selectComment(index_1b);
           pause(0.1) %Allow selection time to take place ...
           str = obj.copySelection();
           %TODO: Need to parse this info
           %contains:
           %1) Channel => * for all channels
           %2) Number => comment id
           %3) Dates? (optional if visible)
           %4) times? (optional if visible)
           %        - this is in the format of the chart display ...
           %        
           %5) the comment string as the remainder
        end
        
        function varargout = copySelection(obj)
            %
            %   str = obj.copySelection()
            
            %I think this may only work if the user doesn't click on
            %anything while it is running :/
            invoke(obj.h,'Copy','Comments View');
            if nargout
                varargout{1} = clipboard('paste');
            end
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
        function selectComment(obj,index_1b)
            %This selects the comment in the commen view window
            %
            %It unfortunately does not select the comment in the chart view
            %
            %This is like double clicking on a comment in chart view ->
            %open to comment with it being selected
            invoke(obj.h,'SelectComment',index_1b);
%             obj.h.SelectComment(index_1b);
        end
        function setCommentText(obj,index_1b,new_text)
            %
            %   Supposedly only works then the comment window
            %   is open but it worked for me when reviewing a file
            invoke(obj.h,'SetCommentText',index_1b,new_text)
        end
        function setCommentsViewFilterText(obj)
            invoke(obj.h,'ShowComment',index_1b);
        end
        function showComment(obj,index_1b)
            %Moves Labchart to the specified commment
            bring_to_front_noop = false; %does nothing currently
            scroll = true;
            animate = true;
            invoke(obj.h,'ShowCommentAdvanced',index_1b,bring_to_front_noop,scroll,animate);
        end
%         function showCommentAdvanced(obj)
%         end

        %These are for in the comments view
        function showDates(obj)
            invoke(obj.h,'ShowCommentsViewDates',true);
        end
        function hideDates(obj)
            invoke(obj.h,'ShowCommentsViewDates',false);
        end
        function showTimes(obj)
            invoke(obj.h,'ShowCommentsViewTimes',true);
        end
        function hideTimes(obj)
            invoke(obj.h,'ShowCommentsViewTimes',false);
        end
    end
    
end

%Closing the Comments Preset Window:
%all Doc.OpenCloseWindow ("{8EC8BD85-CBC1-42DF-A8CF-85021979A2CE}-1", 0, False)


