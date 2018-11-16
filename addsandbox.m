function addsandbox()
%addsandbox Add sandbox to path.
%
%  See also: rmsandbox
%
%  Created using Toolbox Tools v1.1

thisFolder = fileparts( mfilename( 'fullpath' ) );

% Add folders to add to MATLAB path
tbxFolder = fullfile( thisFolder, 'tbx' );
foldersToAdd = toolboxpath(tbxFolder);

% Don't add toolbox directories to saved path

% Add toolbox directories to path
addpath( sprintf( ['%s' pathsep], foldersToAdd{:} ) )

end
