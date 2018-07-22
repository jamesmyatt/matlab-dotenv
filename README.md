# matlab-dotenv

Support setting environment variables from .env file, in order to support
reading configuration from environment variables as in
[12-factor app](https://12factor.net/config).

Based on:
* Javascript: <https://github.com/motdotla/dotenv>
* Python: <https://github.com/theskumar/python-dotenv>
* Ruby: <https://github.com/bkeepers/dotenv>

Unit tests are written using the MATLAB unittest package.

## TODO

* String interpolation using POSIX variable expansion
* Handle escaped quotes in values
* Multi-line values
* Better exceptions
* Default .env file name
* Find .env file by looking in parent directories
* Improve unit tests, especially that:
    * environment variables are modified correctly
* Add proper documentation
