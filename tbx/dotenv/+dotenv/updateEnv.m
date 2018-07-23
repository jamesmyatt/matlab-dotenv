function updateEnv(params, varargin)
%UPDATEENV Update environment variables from map.
%   Existing environment variables are only overriden when 'override' is 
%   set to true.

obj = dotenv.DotEnv(varargin{:});
obj.updateEnv(params);
