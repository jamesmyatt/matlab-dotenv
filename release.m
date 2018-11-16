function release()
%RELEASE Release function to build, test and package the toolbox.
%   The release version is assumed to be up to date in the 'Contents.m'
%   file.
%
%   Created using Toolbox Tools v1.1

%% Set toolbox name, etc.
prjname = 'matlab-dotenv';
tbxname = 'dotenv';
tbxtitle = prjname;

%% Get release script directory
cfdir = fileparts( mfilename( 'fullpath' ) );
tbxDir = fullfile( cfdir, 'tbx');

%% Add sandbox to MATLAB path
run( fullfile( cfdir, 'addsandbox.m' ) );

%% Check MATLAB and related tools, e.g.:
assert( ~verLessThan( 'MATLAB', '9.0' ), 'MATLAB R2016a or higher is required.' )

%% Check installation
fprintf( 1, 'Checking installation...' );
v = ver( tbxname );
switch numel( v )
    case 0
        fprintf( 1, ' failed.\n' );
        error( '%s not found.', tbxname );
    case 1
        % OK so far
        fprintf( 1, ' Done.\n' );
    otherwise
        fprintf( 1, ' failed.\n' );
        error( 'There are multiple copies of ''%s'' on the MATLAB path.', tbxname );
end

%% Build documentation & examples
fprintf( 1, 'Generating documentation & examples...' );
try
    % Do something;
    fprintf( 1, ' Done.\n' );
catch e
    fprintf( 1, ' failed.\n' );
    e.rethrow()
end

%Build doc search database
builddocsearchdb( fullfile( tbxDir, 'doc' ));

%% Run tests
fprintf( 1, 'Running tests...' );
tdir = fullfile( fileparts( tbxDir ), 'tests' );
[log, results] = evalc( sprintf( 'runtests( ''%s'' )', tdir ));
if ~any( [results.Failed] )
    fprintf( 1, ' Done.\n' );
else
    fprintf( 1, ' failed.\n' );
    error( '%s', log )
end

%% Setting toolbox version
fprintf( 1, 'Setting toolbox version...' );
try
    prj = fullfile( cfdir, [ prjname, '.prj'] );
    matlab.addons.toolbox.toolboxVersion( prj, v.Version );
    fprintf( 1, ' Done.\n' );
catch e
    fprintf( 1, ' failed.\n' );
    e.rethrow()
end

%% Package toolbox
fprintf( 1, 'Packaging toolbox...' );
try
    prj = fullfile( cfdir, [ prjname, '.prj'] );
    matlab.addons.toolbox.packageToolbox( prj );
    fprintf( 1, ' Done.\n' );
catch e
    fprintf( 1, ' failed.\n' );
    e.rethrow()
end

%% Renaming toolbox package
fprintf( 1, 'Renaming toolbox package...' );
try
    oldMltbx = which( [tbxtitle '.mltbx'] );
    newMltbx = fullfile( fileparts( tbxDir ), [tbxtitle ' v' v.Version '.mltbx'] );
    movefile( oldMltbx, newMltbx )
    fprintf( 1, ' Done.\n' );
catch e
    fprintf( 1, ' failed.\n' );
    e.rethrow()
end

%% Check package
fprintf( 1, 'Checking toolbox package...' );
tver = matlab.addons.toolbox.toolboxVersion( newMltbx );

if strcmp( tver, v.Version )
    fprintf( 1, ' Done.\n' );
else
    fprintf( 1, ' failed.\n' );
    error( 'Package version ''%s'' does not match code version ''%s''.', tver, v.Version )
end

%% Show message
fprintf( 1, 'Created package ''%s''.\n', newMltbx );

end
