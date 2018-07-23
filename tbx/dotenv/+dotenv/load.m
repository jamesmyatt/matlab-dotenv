function load(filename, varargin)
%LOAD Load environment variables from file.

obj = dotenv.DotEnv(varargin{:});
obj.load(filename);
