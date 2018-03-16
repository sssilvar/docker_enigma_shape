function multiSurfaceOverlayOnMri_script(targetList, imgName, surfaceNames, outputDir, surfColor,...
    varargin)
% Overlays many surfaces at a time on the MRI - detailed view.
%
% multiSurfaceOverlayOnMri_script(targetList, imgName, surfaceNames, outputDir, surfColor,...
%       <overlayFlag([0],1,2)>, <imgFormat>, <annnotFlag(0,1,[2])>, <scaleIntensitiesFlag>, <IsDisplaySliceNumber>)
%
% targetList: it should have absolute paths (without slash ending)
%             E.g: ls -1d /ensc/absolutepath/directoryWithManySubjects/* > targetList
%
% imgName: string specifying the name of MRI in each of the subject directories
%
% surfaceNames: cell array of surface names to be overlayed on MRI.
%               E.g. {'target_auto_surface_lhipp.byu','target_fs_lhipp.byu'} to 
%               compare auto left hippocampus with its freesurfer counterpart
%
% It is assumed that the image and the surfaces exists in each of folders
% specfied in targetList
%
% outputDir:    the place to store results
%
% surfColor:    cell array of RGB formated color strings, Eg { [1 0 0] [0 0.3 1] }. 
%               Must have as many colors as number of surfaces supplied.
%              
% overlayFlag: when 1, produces separate screenshots for each
%               surface, but on the exact same MRI slices for all. Useful for careful
%               examination of different segmentations. bounding box in
%               each figure decided by all the surfaces
%              when 2, produces separate screenshots for each
%               surface, bounding box in each figure decided by the respective
%               surface displayed
%              <DEFAULT> 0, overlays all surfaces in one figure.
%                bounding box in each figure decided by all the surfaces
%
% imgFormat: any allowed image format - <DEFAULT> 'png'. Refer to 'doc print'.
%
% annotFlag:    0 --> no path/legends displayed
%               1 --> only legends are displayed
%               2 --> <DEFAULT> both path and legends are displayed
%
% scaleIntensitiesFlag: whether to scale the gray level MR intensities in ROI being displayed
%               - 0 by default. 
%		- Specity 1 to scale to ROI. 
%
% IsDisplaySliceNumber: whether to display the slice numbers on the overlay
%               - false by default. Specity True/1 to display slice numbers
%
% Eg:multiSurfaceOverlayOnMri_script('short_list_detailed_surface_overlay', 'orig.img' ,...
% {'target_auto_surface_lhipp.byu', 'target_auto_surface_rhipp.byu'}, '~/GAUSS/deleteme', { [1 0 0] [0 0.3 1] }, 1, 'png' )
%
%
% Require's Freesurfer's matlab folder to be in the path

if length(surfColor) < length(surfaceNames)
    error('Insufficient number of surface colors');
end

% Type of overlay
overlayFlag=0;
if nargin > 5
    overlayFlag=varargin{1};
end

% Image format
imgFormat='-dpng';
if nargin > 6
    imgFormat= varargin{2} ;
    if ( isempty(imformats(imgFormat)) )
        imformats
        error('MultiSurfaceOverlay:Pradeep:ImageFormatCheck','Unrecognized ImageFormat  - use one of the above EXT');
    end
    imgFormat=[ '-d' imgFormat ];
end


% Type of annotation
annotFlag=2;
if nargin > 7
    annotFlag= varargin{3} ;
end

% whether to scale the gray level MR intensities in ROI being displayed
scaleIntensitiesFlag=1;
if nargin > 8
    scaleIntensitiesFlag= varargin{4} ;
end

% whether to display the slice numbers on the overlay
IsDisplaySliceNumber=false;
if nargin > 9
    IsDisplaySliceNumber= varargin{5};
end


if ~exist(outputDir,'dir')
    mkdir(outputDir);
end
subjlist = textread(targetList,'%s');

[tmp,id,ext] = cellfun(@fileparts, subjlist,'uniformOutput',false);
id = cellfun(@strcat,id,ext,'uniformoutput',false);
multiSurfaceOverlayOnMri_batch(...
    surfaceNames,subjlist,...
    sxcellfun(@fullfile,subjlist, {imgName} ),...
    sxcellfun(@fullfile,{outputDir}, id),...
    surfColor, imgFormat, overlayFlag, annotFlag, scaleIntensitiesFlag, IsDisplaySliceNumber);

% sxcellfun(@fullfile,{outputDir}, sxcellfun(@strcat,id,{['_' commonOutName '.png']}))

end
