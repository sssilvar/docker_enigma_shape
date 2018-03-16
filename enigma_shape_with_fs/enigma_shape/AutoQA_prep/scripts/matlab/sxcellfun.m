function varargout = sxcellfun(func, varargin)
% cellfun with singleton expansion - Apply a function to each cell of a cell array
% varargout = sxcellfun(func, varargin)
% sxcellfun(func,C,D) executes a func on each cell of cell arrays C and D
%   such that calls are of the form func(c(1),d(1)) etc.
%   unlike cellfun, which requires all parameters (C,D) to have the same
%   size, sxcellfun allows any dimension of any parameter to be 1, in
%   which case it will be virtually replicated
% func - function pointer that accepts the same number of parameters as
%        you have provided cells
% Remaining parameters - cells containing parameters;
%        can also be scalars in which case it will be
%        treated as a cell that is singleton in all
%        dimensions
    lastCell = find(~cellfun(@iscell, cat(2,varargin,1)),1,'first')-1;
    args = cellfun(@wrapInCell,varargin(1:lastCell),'uniformoutput',false);
    [outputSize,outputIndices, inputIndices] = buildCoords(args{:});
    
    expand = struct('type','{}','subs',{{':'}});
    varargout=cell(nargout,1);
    [varargout{:}] = arrayfun(@(varargin) callOnce(func,args, varargin{:}), inputIndices{:},'uniformoutput',false);
end

function varargout = callOnce(func, args, varargin)
varargout = cell(1,nargout);
tmpCell=cellfun(@(x,y) x{y},args,varargin,'uniformoutput',false);
[varargout{:}]=func(tmpCell{:});
end

function x=wrapInCell(x)
    if ~iscell(x)
        x={x};
    end
end


function [outputSize, outputCoords, inputCoords] = buildCoords(varargin)
dimensions = max(cellfun(@(x) ndims(x),varargin));
for it = 1:dimensions
    sizes = cellfun(@(x) size(x,it),varargin);
    if any(~ismember(sizes,[1,max(sizes(sizes~=1))]))
        error('mial:something:buildCoords','Arguments cannot have 2 different non-one sizes in any one dimension');
    end
    if all(sizes==1)
        outputSize(1,it) = max(sizes);
    else
        outputSize(1,it) = max(sizes(sizes~=1));
    end
end
testLabels = cell(outputSize);

tmp = cellfun(@(x) 1:x,num2cell(outputSize),'uniformoutput',false);
outputCoords = cell(size(outputSize,2),1);
[outputCoords{:}] = ndgrid(tmp{:});

mysize = @(x) arrayfun(@(y) size(x,y),1:dimensions);
inputCoords = cellfun(@(x)  cellfun(@(y,z) rem(z-1,y)+1, num2cell(mysize(x))',outputCoords,'uniformoutput',false), varargin,'uniformoutput',false);
multiSub2ind = @(x,y) sub2ind(size(y),x{:});
inputCoords = cellfun(multiSub2ind, inputCoords,varargin,'uniformoutput',false);

outputCoords = multiSub2ind(outputCoords, testLabels);
end