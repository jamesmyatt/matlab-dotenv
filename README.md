# matlab-dotenv

Loads environment variables from .env file in MATLAB. Supports
reading configuration from environment variables as in
[12-factor app](https://12factor.net/config).

This is early alpha software and the interfaces may change at any time.

Unit tests are written using the MATLAB unittest package.

Based on:
* Ruby: <https://github.com/bkeepers/dotenv>
* Javascript: <https://github.com/motdotla/dotenv>
* Python: <https://github.com/theskumar/python-dotenv>

## TODO

* Add Contents.m file [with version information](https://uk.mathworks.com/matlabcentral/answers/266816-how-to-programmatically-get-custom-matlab-toolbox-version)
* String interpolation using POSIX variable expansion
* Handle escaped quotes in values
* Multi-line values
* Better exceptions
* Default .env file name
* Find .env file by looking in parent directories
* Read multiple files and merge results
* Skip files that are missing (?)
* Improve unit tests, especially that:
    * environment variables are modified correctly
* Add proper documentation
* Package as MATLAB toolbox (`.mltbx`) [based on this](https://github.com/mathworks/robust-matlab-2018)

## Changes

### v0.3.0

* Re-organise with tbx directory

### v0.2.0

* Internal refactoring
* Remove support for inline comments and quoted names
* Add "cell" mapping type
* Minor improvements to unit tests

### v0.1.0

* Initial implementation
