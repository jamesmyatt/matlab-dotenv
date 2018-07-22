function [s, quote] = normaliseString(s, quotes)
%NORMALISESTRING 

% Remove matching quotes from start and end
if nargin < 2
    quotes = {'''', '"'};
end
if numel(s) >= 2 && s(1) == s(end) && any(s(1) == quotes)
    quote = s(1);
    s = s(2:end-1);
else
    quote = '';
end

% Replace new lines when quote is "
if quote == '"'
    s = strrep(s, '\n', newline);
end
