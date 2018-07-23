classdef Test_EnvParser < matlab.unittest.TestCase
    %TEST_ENVPARSER Tests on EnvParser class.
    
    properties (TestParameter)
        %LINE
        %   values are {input text, expected key, expected value, expected comment}
        line = struct( ...
            'all_empty', {{'', '', '', ''}}, ...
            'only_whitespace', {{'       ', '', '', ''}}, ...
            'only_comment', {{'# Comment', '', '', 'Comment'}}, ...
            'comment_and_whitespace', {{'    #  Comment   ', '', '', 'Comment'}}, ...
            'simple_assignment', {{'K=V', 'K', 'V', ''}}, ...
            'export_assignment', {{'export K=value', 'K', 'value', ''}}, ...
            'value_double_quotes', {{'name="value"', 'name', 'value', ''}}, ...
            'value_single_quotes', {{'name=''value''', 'name', 'value', ''}}, ...
            'quoted_quotes_single', {{'name="va''lue"', 'name', 'va''lue', ''}}, ...
            'quoted_quotes_double', {{'name=''va"lue''', 'name', 'va"lue', ''}}, ...
            'key_double_quotes', {{'"name"=value', 'name', 'value', ''}}, ...
            'key_single_quotes', {{'''name''=value', 'name', 'value', ''}}, ...
            'key_with_spaces', {{'"complex name"=value', 'complex name', 'value', ''}}, ...
            'key_with_spaces_unquoted', {{'complex name=value', 'complex name', 'value', ''}}, ...
            'value_with_spaces', {{'DB_NAME=my database', 'DB_NAME', 'my database', ''}}, ...
            'value_with_spaces_with_whitespace', {{'  DB_NAME =  my database    ', 'DB_NAME', 'my database', ''}}, ...
            'value_quotes_and_whitespace', {{'  DB_NAME = " my database  "   ', 'DB_NAME', ' my database  ', ''}}, ...
            'empty_value', {{'K=', 'K', '', ''}}, ...
            'empty_value_quoted', {{'K=""', 'K', '', ''}}, ...
            'multiline_value_unquoted', {{'KEY = abc\ndef', 'KEY', 'abc\ndef', ''}}, ...
            'multiline_value_single_quoted', {{'KEY = ''abc\ndef''', 'KEY', 'abc\ndef', ''}}, ...
            'multiline_value_double_quoted', {{'KEY = "abc\ndef"', 'KEY', sprintf('abc\ndef'), ''}}, ...
            'all_parts', {{' export  ''name'' =  "value"  #  Comment   ', 'name', 'value', 'Comment'}}, ...
            'with_CR_leftover', {{sprintf(' export  ''name'' =  "value"  #  Comment \r'), 'name', 'value', 'Comment'}} ...
            );
        %LINE_UNSUPPORTED
        %   values are {input text, correct key, correct value, correct comment}
        %   or {input text, correct exception}
        line_unsupported = struct( ...
            'quoted_comment_in_middle', {{'name=va"#"lue', 'DOTENV:EnvParser:UnmatchedQuotes'}}, ...
            'escaped_quote', {{'name="va\"lue"', 'name', 'va"lue', ''}}, ...
            'escaped_quote_single', {{'name=''va\''lue''', 'name', 'va''lue', ''}}, ...
            'escaped_quote_unquoted', {{'name=va\"lue', 'name', 'va"lue', ''}} ...
            );
        %LINE_INVALID
        %   values are {input text, expected exception}
        line_invalid = struct( ...
            'no_equals', {{'value', 'DOTENV:EnvParser:MissingEquals'}}, ...
            'empty_key', {{'=value', 'DOTENV:EnvParser:EmptyName'}}, ...
            'unmatched_quote_start', {{'key=''value', 'DOTENV:EnvParser:UnmatchedQuotes'}}, ...
            'unmatched_quote_middle', {{'key=va"lue', 'DOTENV:EnvParser:UnmatchedQuotes'}}, ...
            'unmatched_quote_finish', {{'key=value"', 'DOTENV:EnvParser:UnmatchedQuotes'}}, ...
            'unmatched_quote_escaped', {{'key="value\"', 'DOTENV:EnvParser:UnmatchedQuotes'}}, ...
            'mismatched_quotes', {{'name=''value"', 'DOTENV:EnvParser:UnmatchedQuotes'}} ...
            );
        
        %DATA
        %   values are {input text, expected struct}
        data = struct( ...
            'empty', {{'', struct()}}, ...
            'no_data', {{' # all comments\n\n  #   and whitespace\n\n', struct()}}, ...
            'simple_data', {{'A = B\nC=5\nDB_NAME=my database', struct('A', 'B', 'C', '5', 'DB_NAME', 'my database')}}, ...
            'complex_data', {{'   #  complex file\n export A = B\n\n"C_VALUE"="500"\n  DB_NAME  = my database   # Database name', struct('A', 'B', 'C_VALUE', '500', 'DB_NAME', 'my database')}} ...
            );
        %DATA_INVALID
        %   values are {input text, output type, expected exception}
        data_invalid = struct( ...
            'duplicate_name_map', {{'name=A\nname=B', 'map', 'DOTENV:DuplicateNames'}}, ...
            'duplicate_name_struct', {{'name=A\nname=B', 'struct', 'DOTENV:DuplicateNames'}}, ...
            'invalid_name_struct', {{'complex name=1', 'struct', 'MATLAB:Cell2Struct:InvalidFieldName'}} ...
            );
    end
    
    %% Tests on parseLine method
    methods (Test)
        function testLineParsedCorrectly(testCase, line)
            % Tests that each line is parsed correctly
            p = dotenv.EnvParser();
            [k, v, c] = p.parseLine(line{1});
            
            testCase.verifyEqual(k, line{2});
            testCase.verifyEqual(v, line{3});
            testCase.verifyEqual(c, line{4});
        end
        function testLineParsedCorrectlyWhenString(testCase, line)
            % Tests that each line is parsed correctly
            p = dotenv.EnvParser();
            [k, v, c] = p.parseLine(string(line{1}));
            
            testCase.verifyEqual(k, line{2});
            testCase.verifyEqual(v, line{3});
            testCase.verifyEqual(c, line{4});
        end
        function testUnsupportedLineNotParsedCorrectly(testCase, line_unsupported)
            % Tests for lines that are not yet parsed correctly.
            % Will fail when support is added for those lines
            p = dotenv.EnvParser();
            text = line_unsupported{1};

            identifier = '<no exception>';
            try
                [k, v, c] = p.parseLine(text);
            catch me
                identifier = me.identifier;
            end
            
            switch numel(line_unsupported)
                case 2
                    % Proper behaviour is to throw specific exception
                    testCase.assertNotEqual(identifier, line_unsupported{2});
                    
                case 4
                    % Proper behaviour is to return value
                    if strcmp(identifier, '<no exception>')
                        % Check returned at least one incorrect values
                        count_correct = isequaln(k, line_unsupported{2}) + ...
                                isequaln(v, line_unsupported{3}) + ...
                                isequaln(c, line_unsupported{4});
                        testCase.verifyLessThan(count_correct, 3, ...
                            'Correct outputs were obtained, when expected to be different.')
                    else
                        % Exception occured
                    end
                    
                otherwise
                    error('Invalid test specification.')
            end
        end
        
        function testInvalidLineThrowsException(testCase, line_invalid)
            % Tests exception thrown for invalid lines
            p = dotenv.EnvParser();
            text = line_invalid{1};
            testCase.assertError(@() p.parseLine(text), line_invalid{2});
        end
    end
    
    %% Tests on parse method
    methods (Test)
        function testParseReturnsMapByDefault(testCase)
            p = dotenv.EnvParser();
            text = sprintf('');
            out = p.parse(text);
            testCase.assertClass(out, 'containers.Map');
            testCase.verifyEqual(out.KeyType, 'char');
            testCase.verifyEqual(out.ValueType, 'any');
        end
        function testParseReturnsCorrectMap(testCase)
            p = dotenv.EnvParser('map');
            text = sprintf('KEY = B\nC=5\n');
            out = p.parse(text);
            testCase.assertClass(out, 'containers.Map');
            testCase.verifyEqual(sort(out.keys()), {'C', 'KEY'});  % note row
            testCase.verifyEqual(out('KEY'), 'B');
            testCase.verifyEqual(out('C'), '5');
        end
        function testParseReturnsCorrectStruct(testCase)
            p = dotenv.EnvParser('struct');
            text = sprintf('KEY = B\nC=5\n');
            out = p.parse(text);
            testCase.assertClass(out, 'struct');
            testCase.verifyEqual(sort(fieldnames(out)), {'C'; 'KEY'});  % note column
            testCase.verifyEqual(out.KEY, 'B');
            testCase.verifyEqual(out.C, '5');
        end
        
        function testLinesParsedCorrectly(testCase, data)
            p = dotenv.EnvParser('struct');
            text = sprintf(data{1});
            out = p.parse(text);
            testCase.verifyEqual(out, data{2});
        end
        function testLinesParsedCorrectlyWithWindowsEndings(testCase, data)
            p = dotenv.EnvParser('struct');
            text = sprintf(strrep(data{1}, '\n', '\r\n'));
            out = p.parse(text);
            testCase.verifyEqual(out, data{2});
        end
        function testInvalidLinesThrowsException(testCase, data_invalid)
            % Tests exception thrown for invalid lines
            p = dotenv.EnvParser(data_invalid{2});
            text = sprintf(data_invalid{1});
            testCase.assertError(@() p.parse(text), data_invalid{3});
        end
    end
    
    %% Tests on read method
    methods (Test)
        function testCanReadFile_motdotla(testCase)
            % Test can read example .env file correctly
            % This file comes from https://github.com/motdotla/dotenv/blob/master/tests/.env
            
            filename = fullfile(fileparts(mfilename('fullpath')), '.env.motdotla');
            p = dotenv.EnvParser('map');
            out = p.read(filename);
            testCase.assertClass(out, 'containers.Map');
            testCase.verifyEqual(out.length(), 15); 
            testCase.verifyEqual(out('NODE_ENV'), 'development');
            testCase.verifyEqual(out('BASIC'), 'basic');
            testCase.verifyEqual(out('AFTER_LINE'), 'after_line');
            testCase.verifyEqual(out('UNDEFINED_EXPAND'), '$TOTALLY_UNDEFINED_ENV_KEY');
            testCase.verifyEqual(out('EMPTY'), '');
            testCase.verifyEqual(out('SINGLE_QUOTES'), 'single_quotes');
            testCase.verifyEqual(out('DOUBLE_QUOTES'), 'double_quotes');
            testCase.verifyEqual(out('EXPAND_NEWLINES'), sprintf('expand\nnewlines'));
            testCase.verifyEqual(out('DONT_EXPAND_NEWLINES_1'), 'dontexpand\nnewlines');
            testCase.verifyEqual(out('DONT_EXPAND_NEWLINES_2'), 'dontexpand\nnewlines');
            testCase.verifyEqual(out('EQUAL_SIGNS'), 'equals==');
            testCase.verifyEqual(out('RETAIN_INNER_QUOTES'), '{"foo": "bar"}');
            testCase.verifyEqual(out('RETAIN_INNER_QUOTES_AS_STRING'), '{"foo": "bar"}');
            testCase.verifyEqual(out('INCLUDE_SPACE'), 'some spaced out string');
            testCase.verifyEqual(out('USERNAME'), 'therealnerdybeast@example.tld');
        end
    end
end
