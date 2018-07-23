function params = read(filename, varargin)
%READ Read variables from file.

obj = dotenv.DotEnv(varargin{:});
params = obj.read(filename);
