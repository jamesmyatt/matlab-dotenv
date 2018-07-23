function [keys, values] = extractKeysAndValues(mapping)
%EXTRACTKEYSANDVALUES Extract keys and values from mapping.

if isa(mapping, 'containers.Map')
    [keys, values] = extractMap(mapping);
elseif isstruct(mapping)
    [keys, values] = extractStruct(mapping);
elseif iscell(mapping)
    [keys, values] = extractCell(mapping);
else
    error('Invalid input type');
end

% Ensure outputs are column vectors
keys = keys(:);
values = values(:);

end

function [keys, values] = extractMap(mapping)
keys = mapping.keys();
values = mapping.values();
end

function [keys, values] = extractStruct(mapping)
keys = fieldnames(mapping);
values = struct2cell(mapping);
end

function [keys, values] = extractCell(mapping)
if isempty(mapping)
    keys = {};
    values = {};
else
    if size(mapping, 2) ~= 2
        error('Invalid mapping')
    end
    keys = mapping(:, 1);
    values = mapping(:, 2);
end
end
