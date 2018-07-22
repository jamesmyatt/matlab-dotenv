function [keys, values] = extractKeysAndValues(mapping)
%EXTRACTKEYSANDVALUES Extract keys and values from mapping.

if isa(mapping, 'containers.Map')
    [keys, values] = extractMap(mapping);
elseif isstruct(mapping)
    [keys, values] = extractStruct(mapping);
else
    error('Invalid input type');
end

end

function [keys, values] = extractMap(mapping)
keys = mapping.keys();
values = mapping.values();
end

function [keys, values] = extractStruct(mapping)
keys = fieldnames(mapping);
values = struct2cell(mapping);
end
