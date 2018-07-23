classdef EnvParser < handle
    %ENVPARSER Parser for .env files.
    
    properties
        mappingType = 'map'
    end
    properties (Constant)
        COMMENTS = '#'
        QUOTES = '''"'
    end
    
    methods
        function obj = EnvParser(type)
            %ENVPARSER Construct parser.
            
            if nargin >= 1
                obj.mappingType = type;
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
            params = dotenv.internal.combineKeysAndValues(obj.mappingType, keys, values);
        end
        
        function [key, value, comment] = parseLine(obj, line)
            %PARSELINE Extract parts from single line.
            
            % TODO: Handle escaped quotes
            % TODO: Validate better
            % TODO: Better string handling
            % TODO: Better exceptions
            
            key = '';
            value = '';
            comment = '';
            
            % Convert string to char and remove padding
            if isstring(line)
                line = char(line);
            end
            line = strtrim(line);
            
            % Parse line
            if isempty(line)
                % empty line
            elseif any(line(1) == obj.COMMENTS)
                % comment
                if nargout >= 3
                    comment = strtrim(line(2:end));
                    if isempty(comment)
                        comment = '';
                    end
                end
            else
                % assignment
                idx_equals = find(line == '=', 1); % Find first equals sign
                if isempty(idx_equals)
                    error('DOTENV:EnvParser:MissingEquals', ...
                        'Assignment missing.')
                else                
                    key = obj.parseName(line(1 : idx_equals-1));
                    value = obj.parseValue(line(idx_equals+1 : end));
                end
            end
        end
        
        function s = parseName(~, s)
            %PARSENAME Convert raw string to variable name.
            
            % Remove padding
            s = strtrim(s);  
            
            % Remove "export" from the start of the key
            if strcmpi(s, 'export')
                s = '';
            elseif strncmpi(s, 'export ', 7)
                s = strtrim(s(7:end));
            end
            
            % Check for empty
            if isempty(s)
                error('DOTENV:EnvParser:MissingName', 'Missing variable name.');
            end
        end
        
        function [s, quote] = parseValue(obj, s)
            %PARSESTRING Convert raw string into variable value.
            
            % Remove padding
            s = strtrim(s);
            
            % Remove matching quotes
            if numel(s) >= 1 && any(s(1) == obj.QUOTES)
                quote = s(1);
                if numel(s) >= 2 && s(end) == quote && s(end-1) ~= '\'
                    s = s(2:end-1);
                else
                    error('DOTENV:EnvParser:UnmatchedQuotes', ...
                        'Unmatched quote: %s', quote);
                end
            else
                quote = '';
            end
            
            % Replace new lines when quote is "
            if quote == '"'
                s = strrep(s, '\n', newline);
            end
            
            % Ensure empty strings match ''
            if isempty(s)
                s = '';
            end
        end
    end
end
