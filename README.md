# matlab-dotenv

Loads environment variables from .env file in MATLAB. Supports
reading configuration from environment variables as in
[12-factor app](https://12factor.net/config).

Based on:
* Ruby: <https://github.com/bkeepers/dotenv>
* Javascript: <https://github.com/motdotla/dotenv>
* Python: <https://github.com/theskumar/python-dotenv>

Unit tests are written using the MATLAB unittest package.

## TODO

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
* Package as MATLAB toolbox (`.mltbx`)
