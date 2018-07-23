classdef Test_EnvParser < matlab.unittest.TestCase
    %TEST_ENVPARSER Tests on EnvParser class.
    
    properties (TestParameter)
        %LINE
        %   values are {input text, correct key, correct value, correct comment}
        %   or {input text, correct exception}
        line = struct( ...
            'all_empty', {{'', '', '', ''}}, ...
            'only_whitespace', {{'       ', '', '', ''}}, ...
            'only_comment', {{'# Comment', '', '', 'Comment'}}, ...
            'comment_and_whitespace', {{'    #  Comment   ', '', '', 'Comment'}}, ...
            ...
            'simple_assignment', {{'K=V', 'K', 'V', ''}}, ...
            'simple_assignment_CR', {{sprintf('K=V\r'), 'K', 'V', ''}}, ...
            'no_equals', {{'value', 'DOTENV:EnvParser:MissingEquals'}}, ...
            'empty_key', {{'=value', 'DOTENV:EnvParser:MissingName'}}, ...
            'export_assignment', {{'export K=value', 'K', 'value', ''}}, ...
            'export_assignment_upper', {{'EXPORT K=value', 'K', 'value', ''}}, ...
            'export_assignment_mixed', {{'Export K=value', 'K', 'value', ''}}, ...
            'empty_key_export', {{'export=value', 'DOTENV:EnvParser:MissingName'}}, ...
            'empty_key_export_spaces', {{'export = value', 'DOTENV:EnvParser:MissingName'}}, ...
            'empty_key_export_upper', {{'EXPORT=value', 'DOTENV:EnvParser:MissingName'}}, ...
            ...
            'value_double_quotes', {{'name="value"', 'name', 'value', ''}}, ...
            'value_single_quotes', {{'name=''value''', 'name', 'value', ''}}, ...
            'quoted_quotes_single', {{'name="va''lue"', 'name', 'va''lue', ''}}, ...
            'quoted_quotes_double', {{'name=''va"lue''', 'name', 'va"lue', ''}}, ...
            'unmatched_quote_start', {{'key=''value', 'DOTENV:EnvParser:UnmatchedQuotes'}}, ...
            'unmatched_quote_double', {{'key="value', 'DOTENV:EnvParser:UnmatchedQuotes'}}, ...
            'unmatched_quote_escaped', {{'key="value\"', 'DOTENV:EnvParser:UnmatchedQuotes'}}, ...
            'unmatched_quote_middle', {{'key=va"lue', 'key', 'va"lue', ''}}, ...
            'unmatched_quote_finish', {{'key=value"', 'key', 'value"', ''}}, ...
            'mismatched_quotes', {{'name=''value"', 'DOTENV:EnvParser:UnmatchedQuotes'}}, ...
            ...
            'value_with_spaces', {{'DB_NAME=my database', 'DB_NAME', 'my database', ''}}, ...
            'value_with_spaces_with_whitespace', {{'  DB_NAME =  my database    ', 'DB_NAME', 'my database', ''}}, ...
            'value_quotes_and_whitespace', {{'  DB_NAME = " my database  "   ', 'DB_NAME', ' my database  ', ''}}, ...
            'name_with_spaces', {{'DB NAME=my database', 'DB NAME', 'my database', ''}}, ...
            'empty_value', {{'K=', 'K', '', ''}}, ...
            'empty_value_quoted', {{'K=""', 'K', '', ''}}, ...
            'comment_inline', {{'name=value # my value', 'name', 'value # my value', ''}}, ...
            'quoted_comment_in_middle', {{'name=va"#"lue', 'name', 'va"#"lue', ''}}, ...
            'escaped_quote_unquoted', {{'name=va\"lue', 'name', 'va\"lue', ''}}, ...
            'multiline_value_unquoted', {{'KEY = abc\ndef', 'KEY', 'abc\ndef', ''}}, ...
            'multiline_value_single_quoted', {{'KEY = ''abc\ndef''', 'KEY', 'abc\ndef', ''}}, ...
            'multiline_value_double_quoted', {{'KEY = "abc\ndef"', 'KEY', sprintf('abc\ndef'), ''}}, ...
            'all_parts', {{' export  name =  "value"', 'name', 'value', ''}}, ...
            'with_CR_leftover', {{sprintf(' export  name =  "value"\r'), 'name', 'value', ''}} ...
            );
        %LINE_UNSUPPORTED
        %   values are {input text, correct key, correct value, correct comment}
        %   or {input text, correct exception}
        line_unsupported = struct( ...
            'escaped_quote', {{'name="va\"lue"', 'name', 'va"lue', ''}}, ...
            'escaped_quote_single', {{'name=''va\''lue''', 'name', 'va''lue', ''}} ...
            );
        
        %DATA_STRUCT
        %   values are {input text, expected struct}
        %   or {input text, expected exception}
        data_struct = struct( ...
            'empty', {{'', cell(0, 2)}}, ...
            'no_data', {{' # all comments\n\n  #   and whitespace\n\n', cell(0, 2)}}, ...
            'simple_data', {{'A = B\nKEY=5\nDB_NAME=my database', {'A', 'B'; 'DB_NAME', 'my database'; 'KEY', '5'}}}, ...
            'complex_data', {{'   #  complex file\n export A = B\n\nVALUE="500"\n  DB_NAME  = my database', {'A', 'B'; 'DB_NAME', 'my database'; 'VALUE', '500'}}}, ...
            'duplicate_name', {{'name=A\nname=B', 'DOTENV:DuplicateNames'}}, ...
            'invalid_name', {{'complex name=1', 'MATLAB:Cell2Struct:InvalidFieldName'}} ...
            );
        %DATA_MAP
        %   values are {input text, expected struct}
        %   or {input text, expected exception}
        data_map = struct( ...
            'empty', {{'', cell(0, 2)}}, ...
            'no_data', {{' # all comments\n\n  #   and whitespace\n\n', cell(0, 2)}}, ...
            'simple_data', {{'A = B\nKEY=5\nDB_NAME=my database', {'A', 'B'; 'DB_NAME', 'my database'; 'KEY', '5'}}}, ...
            'complex_data', {{'   #  complex file\n export A = B\n\nVALUE="500"\n  DB_NAME  = my database', {'A', 'B'; 'DB_NAME', 'my database'; 'VALUE', '500'}}}, ...
            'duplicate_name', {{'name=A\nname=B', 'DOTENV:DuplicateNames'}}, ...
            'invalid_name', {{'complex name=1', {'complex name', '1'}}} ...
            );
    end
    
    %% Tests on parseLine method
    methods (Test)
        function testLineParsedCorrectly(testCase, line)
            % Tests that each line is parsed correctly
            text = line{1};
            testCase.checkLine(text, line(2:end))
        end
        function testLineParsedCorrectlyWhenString(testCase, line)
            % Tests that each line is parsed correctly
            text = string(line{1});
            testCase.checkLine(text, line(2:end))
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
                        testCase.assertNotEqual(identifier, '<no exception>');
                    end
                    
                otherwise
                    error('Invalid test specification.')
            end
        end
    end
    
    methods
        function checkLine(testCase, text, expected)
            % Checks that each line is parsed correctly
            p = dotenv.EnvParser();
            f = @() p.parseLine(text);
            
            switch numel(expected)
                case 1
                    testCase.assertError(f, expected{1});
                    
                case 2
                    [k, v] = f();
                    
                    testCase.verifyEqual(k, expected{1});
                    testCase.verifyEqual(v, expected{2});
                    
                case 3
                    [k, v, c] = f();
                    
                    testCase.verifyEqual(k, expected{1});
                    testCase.verifyEqual(v, expected{2});
                    testCase.verifyEqual(c, expected{3});
            end
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
        
        function testLinesParsedCorrectlyToStruct(testCase, data_struct)
            text = sprintf(data_struct{1});
            testCase.checkMapping(text, data_struct{2}, 'struct');
        end
        function testLinesParsedCorrectlyToMap(testCase, data_map)
            text = sprintf(data_map{1});
            testCase.checkMapping(text, data_map{2}, 'containers.Map');
        end
        function testLinesParsedCorrectlyWithWindowsEndings(testCase, data_struct)
            text = sprintf(strrep(data_struct{1}, '\n', '\r\n'));
            testCase.checkMapping(text, data_struct{2}, 'struct');
        end
    end
    
    methods
        function checkMapping(testCase, text, expected, expectedType)
            if strcmp(expectedType, 'containers.Map')
                p = dotenv.EnvParser('map');
            else
                p = dotenv.EnvParser(expectedType);
            end
            
            f = @() p.parse(text);
            
            if ischar(expected)
                testCase.assertError(f, expected);
            else
                output = f();
                
                testCase.verifyClass(output, expectedType);
                
                [keys, values] = dotenv.internal.extractKeysAndValues(output);
                [keys, idx_sorted] = sort(keys);
                values = values(idx_sorted);
                
                testCase.verifyEqual(keys(:), expected(:, 1));
                testCase.verifyEqual(values(:), expected(:, 2));
            end
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
