function rmsandbox()
%rmsandbox Remove sandbox from path.
%
%  See also: addsandbox
%
%  Created using Toolbox Tools v1.1

thisFolder = fileparts( mfilename( 'fullpath' ) );

% Add folders to remove from MATLAB path
tbxFolder = fullfile( thisFolder, 'tbx' );
foldersToRemove = toolboxpath(tbxFolder);

% Toolbox directories assumed not to be in saved path

% Remove toolbox directories from path
rmpath( sprintf( ['%s' pathsep], foldersToRemove{:} ) );

end
