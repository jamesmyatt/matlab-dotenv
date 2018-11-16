# matlab-dotenv

Reads the key,value pair from `.env` file and adds them to the environment
variables. It is great for managing app settings during development and
in production using [12-factor](http://12factor.net/) principles.

This is early alpha software and the interfaces may change at any time.

Unit tests are written using the MATLAB unittest package.

Influences:

* Python: [python-dotenv](https://github.com/theskumar/python-dotenv)
* R: [dotenv](https://github.com/gaborcsardi/dotenv)
* Node.js: [dotenv](https://github.com/motdotla/dotenv)
* Ruby: [dotenv](https://github.com/bkeepers/dotenv)

Plan is to focus only on core functionality and then to follow the example
of python-dotenv in the case of any conflicts.

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
* Improve documentation

## Changes

### v0.3.0

* Add Contents.m file
* Package as MATLAB toolbox (`.mltbx`)
* Initial version of HTML help

### v0.2.0

* Internal refactoring
* Remove support for inline comments and quoted names
* Add "cell" mapping type
* Minor improvements to unit tests

### v0.1.0

* Initial implementation
