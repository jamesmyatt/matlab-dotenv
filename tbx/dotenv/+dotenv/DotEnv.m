classdef DotEnv < handle
    %DOTENV Controller for setting environment from .env files.
    
    properties
        verbose(1,1) logical = false
        override(1,1) logical = false
        parser = []
    end
    
    methods
        function obj = DotEnv(varargin)
            %DOTENV Construct an instance of this class
            
            obj.parser = dotenv.EnvParser();
            
            for idx = 1:2:numel(varargin)
                switch varargin{idx}
                    case {'verbose', 'override'}
                        obj.(varargin{idx}) = varargin{idx + 1};
                    case {'mappingType'}
                        obj.parser.(varargin{idx}) = varargin{idx + 1};
                    otherwise
                        error('Invalid property name');
                end
            end
        end
        
        function params = read(obj, filename)
            %READ Read environment variables from file.
            % TODO: Read multiple files and merge results
            params = obj.parser.read(filename);
        end
        function load(obj, filename)
            %LOAD Load environment variables from file.
            params = obj.read(filename);
            obj.updateEnv(params);
        end
        
        function updateEnv(obj, params)
            %UPDATEENV Update environment variables from map.
            %   Existing environment variables are only overriden when 'override' is
            %   set to true.
            %
            %   See also parse.
            
            % Extract key-value pairs
            [keys, values] = dotenv.internal.extractKeysAndValues(params);
            
            % Update environment variables
            for idx = 1:numel(keys)
                if obj.override || isempty(getenv(keys{idx}))
                    if obj.verbose
                        fprintf('%s = %s\n', keys{idx}, values{idx});
                    end
                    setenv(keys{idx}, values{idx})
                end
            end
        end
    end
end
