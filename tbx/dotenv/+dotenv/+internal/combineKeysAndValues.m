function mapping = combineKeysAndValues(type, keys, values)
%COMBINEKEYSANDVALUES Combine keys and values into mapping.

% TODO: Do we need to check for invalid keys?

% Check inputs
checkForDuplicateNames(keys)

% Build output
typeMap.map = @createMap;
typeMap.struct = @createStruct;
typeMap.cell = @createCell;

if isfield(typeMap, lower(type))
    mapping = typeMap.(lower(type))(keys, values);
else
    error('Invalid output type: %s', type);
end

end

function mapping = createMap(keys, values)
if isempty(keys)
    mapping = containers.Map('KeyType', 'char', 'ValueType', 'any');
else
    mapping = containers.Map(keys, values, 'UniformValues', false);
end
end

function mapping = createStruct(keys, values)
mapping = cell2struct(values(:), keys(:), 1);
end

function mapping = createCell(keys, values)
if isempty(keys) ~= isempty(values)
    error('Mismatched inputs')
end
mapping = [keys(:), values(:)];
end

function checkForDuplicateNames(keys)
% check for duplicate fields

[u_names, ia, ~] = unique(keys);
if numel(u_names) < numel(keys)
    names_dup = keys;
    names_dup(ia) = [];
    names_dup = unique(names_dup);
    
    if numel(names_dup) > 9
        names_dup(10:end) = [];
        names_dup{9} = '...';
    end
    
    error('DOTENV:DuplicateNames', ...
        'Duplicate names detected: %s', join(string(names_dup), ", "))
end

end
