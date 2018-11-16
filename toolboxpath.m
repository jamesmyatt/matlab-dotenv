function tbxFolders = toolboxpath(tbxFolder)
%TOOLBOXPATH Find folders to add to MATLAB path.
%
%   See also: addsandbox, rmsandbox.

fl = dir(tbxFolder);

fl(~[fl.isdir]) = [];
fl(strncmp({fl.name}, '.', 1)) = [];
fl(strcmp({fl.name}, 'doc')) = []; % Remove documentation

tbxFolders = [
    tbxFolder;
    strcat( [tbxFolder filesep], {fl.name}' )
    ];
