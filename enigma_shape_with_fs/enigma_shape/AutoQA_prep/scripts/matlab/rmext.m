function fname = rmext(filenameExt)

% Look for EXTENSION part
ind = find(filenameExt == '.', 1, 'last');
if isempty(ind)
    fname = filenameExt;
else
    fname = filenameExt(1:ind-1);
end
