function output = findMatches(input_string,strings_to_match,varargin)
%x  Tries to find a match for one string in a set of strings based on rules
%
%   mask_or_indices = sl.str.findMatches(input_string_or_pattern,string_options,varargin)
%
%   Inputs:
%   -------
%   input_string : string
%   strings_to_match : cellstr
%
%   Optional Inputs:
%   ----------------
%   n_rule : (default 2)
%       Rule for interpreting the # of matches obtained.
%       - 0, only match zero or 1 result
%       - 1, match one, but rule can trim (see 'multi_result_rule')
%            i.e. we can find many, but filter down to 1 based on the
%            'multi_result_rule' flag value
%            - the default behavior here is that if a single match is
%            not found to throw an error
%       - 2, any amount
%   as_mask :  (default false) (length = length(strings_to_match))
%       true - output is logical mask, indicating matches
%       false - output is an array of indices of matches
%   case_sensitive : (default false)
%       Whether or not the search should be case sensitive.
%   partial_match : (default false)
%       If true the input only needs to be a part of the matching string.
%   regex : (default false)
%       If true, the input is a regexp pattern that should be matched.
%   multi_result_rule: string (default 'error')
%       - 'error'
%           Always throw an error if this occurs.
%       - 'first'
%       - 'last'
%       - 'exact_or_error'
%           In this case, there must be an exact match, otherwise there
%           is an error. This allows a non-exact match, if there is only
%           one possible match.
%
%       - index # - e.g. 3, this basically says, I expect that my answer
%       will include this particular index, and that if true, I want to use
%       it (otherwise throw an error)
%       - 'shortest'
%   unique_multi_match: (default false)
%       If true, all matches must be the same. For example, the following
%       would throw an error for a partial match to 'as':
%           {'past','last','last','past'}
%                   <= error if unique_multi_match is true
%
%   Improvements
%   ------------
%   Supply custom error messages
%
%   Examples
%   --------
%   1) Find the pressure signal
%   mask_or_indices = sl.str.findMatches('pres',{'Bladder Pressure','EUS EMG'},'partial_match',true);
%
%   2) Find the pressure signal - spelling error, not found
%   THROWS AN ERROR
%   %Options: 'n_rule',1 => must find 1 match
%   mask_or_indices = sl.str.findMatches('pres',{'Bladder ressure','EUS EMG'},'partial_match',true,'n_rule',1);
%
%
%   3) Find the pressure signal - multiple pressures
%   %Options: 'multi_result_rule','first' => return the first match (in
%   %           this case the bladdre pressure)
%   mask_or_indices = sl.str.findMatches('pres',{'Bladder pressure','Urethral Pressure','EUS EMG'},...
%           'partial_match',true,'n_rule',1,'multi_result_rule','first');

%{
mask_or_indices = sl.str.findMatches('asdf',{'ASDF'});


%}

in.n_rule = 2;
in.as_mask = false;
in.case_sensitive = false;
in.partial_match  = false;
in.regex = false;
in.multi_result_rule = 'error';
in.unique_multi_match = false;
in = labchart.sl.in.processVarargin(in,varargin);

if in.partial_match
    mask = cellfun(@(x) labchart.sl.str.contains(x,input_string,'case_sensitive',in.case_sensitive),strings_to_match);
elseif in.regex
    if in.case_sensitive
        fh = @regexp;
    else
        fh = @regexpi;
    end
    regexp_pattern = input_string;
    mask = ~cellfun('isempty',fh(strings_to_match,regexp_pattern));
else
    if in.case_sensitive
        mask = strcmp(strings_to_match,input_string);
    else
        mask = strcmpi(strings_to_match,input_string);
    end
end

n_matches = sum(mask);


%# of results processing
%-----------------------------------------------
I = -1; %Change this to indicate an actual result
switch in.n_rule
    case 0 %only match zero or 1 result
        if n_matches > 1
            error('Multiple matches found for: "%s" but only 0 or 1 allowed',input_string);
        end
    case 1 %match 1, but follow rule
        if n_matches == 0
            error('Match rule needs 1 match but no matches found'); 
        elseif n_matches ~= 1
            switch in.multi_result_rule
                case 'error'
                    if n_matches == 0
                        error('No matches found for: "%s", expecting 1',input_string);
                    else
                        error('Multiple matches found for: "%s" but only 1 allowed',input_string);
                    end
                case 'first'
                    I = find(mask,1);
                case 'last'
                    I = find(mask,1,'last');
                case {'shortest','exact_or_error'}
                    I = find(mask);
                    name_lengths = cellfun('length',strings_to_match(mask));
                    [~,I2] = min(name_lengths);
                    I = I(I2);
                    if strcmp(in.multi_result_rule,'exact_or_error')
                        if in.case_sensitive
                            is_same = strcmp(strings_to_match{I},input_string);
                        else
                            is_same = strcmpi(strings_to_match{I},input_string);
                        end
                        if ~is_same
                            error('Multiple results, but no exact match');
                        end
                    end
                otherwise
                    error('Unhandled case for in.multi_result_rule')
            end
        end
    case 2 %any allowed
        if in.unique_multi_match
            I = find(mask);
            if in.case_sensitive
                all_same = all(strcmp(strings_to_match(I),strings_to_match{I(1)}));
            else
                all_same = all(strcmpi(strings_to_match(I),strings_to_match{I(1)}));
            end
            if ~all_same
                error('Multiple matches found, but matches were not all the same')
            end
        end
        %Go on ...
    otherwise
        error('Unrecognized option for n_rule')
        
end

%Process the output (indices or mask?)
%----------------------------------------
%I = -1 indicates that indices haven't been found
if in.as_mask
    if ~isequal(I,-1)
        output = false(1,length(strings_to_match));
        output(I) = true;
    else
        output = mask;
    end
else
    if ~isequal(I,-1)
        output = I;
    else
        output = find(mask);
    end
end

end