classdef EnvParser < handle
    %ENVPARSER Parser for .env files.
    
    properties
        returnType = 'map'
    end
    properties (Constant)
        QUOTES = '''"'
    end
    
    methods
        function obj = EnvParser(type)
            %ENVPARSER Construct parser.
            
            if nargin >= 1
                obj.returnType = type;
            end
        end
        
        function params = read(obj, filename)
            %READ Read and parse text file.
            
            data = fileread(filename);
            params = obj.parse(data);
        end
        
        function params = parse(obj, data)
            %PARSE Parse text data.
            
            % Parse each line
            lines = strsplit(data, '\n');
            [keys, values, ~] = cellfun( ...
                @obj.parseLine, lines, 'UniformOutput', false);
            
            % Remove empty keys (=> blank line)
            I = cellfun(@isempty, keys);
            keys(I) = [];
            values(I) = [];
            
            % Construct mapping
            params = dotenv.internal.combineKeysAndValues(obj.returnType, keys, values);
        end
        
        function [key, value, comment] = parseLine(obj, line)
            %PARSELINE Extract parts from single line.
            
            % TODO: Handle escaped quotes
            % TODO: Validate better
            % TODO: Better string handling
            % TODO: Better exceptions
            
            % Convert string to char
            if isstring(line)
                line = char(line);
            end
            
            % Scan line to extract parts
            idx_equals = [];
            idx_comment = [];
            quote = '';
            
            for idx = 1:numel(line)
                if isempty(quote)
                    if line(idx) == '#'
                        idx_comment = idx;
                        break  % ignore everything after here
                    elseif any(line(idx) == obj.QUOTES)
                        % Start of quoted text
                        quote = line(idx);
                    elseif isempty(idx_equals) && line(idx) == '='
                        % First equals sign
                        idx_equals = idx;
                    end
                else
                    if line(idx) == quote
                        % End of quoted text
                        quote = '';
                    end
                end
            end
            if ~isempty(quote)
                error('DOTENV:EnvParser:UnmatchedQuotes', ...
                    'Unmatched quote: %s', quote);
            end
            
            % Separate into parts
            if isempty(idx_comment)
                comment = '';
            else
                comment = line(idx_comment+1 : end);
                line = line(1 : idx_comment-1);
            end
            if isempty(idx_equals)
                key = '';
                value = line;
            else
                key = line(1 : idx_equals-1);
                value = line(idx_equals+1 : end);
            end
            
            % Remove padding
            comment = strtrim(comment);
            key = strtrim(key);
            value = strtrim(value);
            
            if isempty(idx_equals) && ~isempty(value)
                error('DOTENV:EnvParser:MissingEquals', 'Assignment missing.')
            end
            
            % Tidy parts
            if strcmpi(key, 'export') || strncmpi(key, 'export ', 7)
                key = strtrim(key(7:end));
            end
            key = obj.normaliseString(key);
            value = obj.normaliseString(value);
            
            if ~isempty(idx_equals) && isempty(key)
                error('DOTENV:EnvParser:EmptyName', 'Empty variable name found.');
            end
            
            % Ensure empty strings match ''
            if isempty(key), key = ''; end
            if isempty(value), value = ''; end
            if isempty(comment), comment = ''; end
        end
        
        function [s, quote] = normaliseString(obj, s)
            %NORMALISESTRING 
            
            % Remove matching quotes from start and end
            if numel(s) >= 2 && s(1) == s(end) && any(s(1) == obj.QUOTES)
                quote = s(1);
                s = s(2:end-1);
            else
                quote = '';
            end
            
            % Replace new lines when quote is "
            if quote == '"'
                s = strrep(s, '\n', newline);
            end
        end
    end
end
