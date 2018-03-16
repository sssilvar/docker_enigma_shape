function ext = fileext(filename)

% Look for EXTENSION part
ind = find(filename == '.', 1, 'last');
if isempty(ind)
    ext = [];
else
    ext = filename(ind:end);
end
