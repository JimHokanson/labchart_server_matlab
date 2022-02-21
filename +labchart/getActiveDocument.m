function active = getActiveDocument(varargin)
%x Retrieve the currently active document in Matlab
%
%   active = labchart.getActiveDocument(varargin)
%
%   Optional Inputs
%   ---------------
%   missing_ok : default false
%       If true, the output will be empty when no document is open.
%       
%
%   Outputs
%   -------
%   active : labchart.document OR []
%       If no document is currently open, this code will throw an error.
%       Alternatively, if 'missing_ok' is set, then [] will be returned.
%
%   Examples
%   ---------
%   d = labchart.getActiveDocument();
%
%   d = labchart.getActiveDocument('missing_ok',true);
%
%   See Also
%   --------
%   labchart.application


in.missing_ok = false;
in = labchart.sl.in.processVarargin(in,varargin);

if in.missing_ok
    running = labchart.application.checkIfRunning();
    if ~running
        active = [];
        return;
    end
end

temp = labchart.application;
active = temp.active_document;

if isempty(active) && ~in.missing_ok
   error('labchart:getActiveDocument','No active document found - i.e. no documents opened in Labchart'); 
end

end