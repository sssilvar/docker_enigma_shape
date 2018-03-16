function fHandles = multiSurfaceOverlayDetailedCheck_v2( imgOrig, verticesOrig, facesOrig, surfColor,...
    pathOfSubject, legends, compareFlag, annotFlag, scaleIntensitiesFlag,...
    IsDisplaySliceNumber ) 

% clear; close all; clc; pathOfSubject = 'something';
% folder = fullfile(getenv('FSLDDMM_HOME'), 'templates', 'unsw4216_HiAm_surf' );
% imgName = fullfile( folder, 'unsw4216_HiAm.img');
% prepend = @(str) ( [ 'surfaces' filesep str ]);
%
% % surfNames = cellfun(prepend, {'surface.rcaud.byu'}, 'UniformOutput',false);
% legends = {'surface.rcaud.byu','surface.rthal.byu'};
% surfNames = cellfun(prepend, legends, 'UniformOutput',false);
% surfColor = { [1 0 1] [0.5 1 0.2] };
% % surfNames = cellfun(prepend, {'surface.rcaud.byu','surface.rthal.byu'}, 'UniformOutput',false);
% % surfNames = cellfun(prepend, {'surface.rcaud.byu','surface.lcaud.byu',...
% %     'surface.lthal.byu','surface.rthal.byu','surface.lamyg.byu','surface.ramyg.byu', 'surface.lhipp.byu','surface.rhipp.byu','surface.lput.byu','surface.rput.byu'}, 'UniformOutput',false);
% % surfColor = { [1 0 1] [1 0 1] [0.5 1 0.2] [0.5 1 0.2] [1 1 0] [1 1 0] [0 0 0] [0 0 0] [0 1 1] [0 1 1] };
% [ imgOrig voxDim ]= readanalyze( imgName );
% verticesOrig = cell(size(surfNames));facesOrig=cell(size(surfNames));
% compareFlag = 0;
% for ss = 1 : length(surfNames)
%     [ parts verticesOrig{ss} edges ] = readBYUSurface([ folder filesep surfNames{ss} ]);
%     facesOrig{ss} = abs(reshape(edges,3,[])');
% end
%
% annotFlag = 0;

if length(verticesOrig)~=length(facesOrig)
    error('lengths of arg 2 and 3 must be same ');
end

surface  = legends{1};
fprintf('Making quickcheck image of %s for %s\n', surface(1:end-4), pathOfSubject);

% some numbers to set the layout etc
surfOutLineWidth = 0.6;
fontSize = 12; % for displayed path and legends.

posSliceNum = [1 3]; % [ 0.1 0.2]; 
fontSizeSliceNum = 3; 
prefixSliceNum = {'A','C','S'};

nCS = 11 ; % number of crosssections

annotPathPos = [ 0   0.51  1 0.03  ]; % path
annotLegdPos = [ -0.047   0.47  1 0.03 ]; % legend


% bringing vertices to the image space
vertices = cell(size(verticesOrig));
for ss = 1 : length(verticesOrig)
    vertices{ss} = [ size(imgOrig,1)-verticesOrig{ss}(:,1), size(imgOrig,2)-verticesOrig{ss}(:,2), size(imgOrig,3)-verticesOrig{ss}(:,3)];
end

% to comply with brainworks layout
%permuteOrder = [ 3 2 1]; %LAS
permuteOrder = [ 2 3 1 ]; %LIA
img = permute(imgOrig , permuteOrder);
for ss = 1 : length(vertices)
    vertices{ss} = vertices{ss}( :, permuteOrder);
end
% flipping dimension 1 to get sagittal and coronal views upright
%img = flipdim(img,1 );
%for ss = 1 : length(vertices)
%    vertices{ss}(:,1) = size(img,1) - vertices{ss}(:,1) +1 ;
%end

range = NaN(nCS,3);
for dimIt = 1:ndims(img)
    minmin = +Inf; maxmax = -Inf;
    for ss = 1 : length(vertices)
        minmin = min( minmin, min(vertices{ss}(:,dimIt) ) );
        maxmax = max( maxmax, max(vertices{ss}(:,dimIt) ) );
    end

    % making sure the range doesn't exceed the image boundaries
    minmin = max(1, minmin);
    maxmax = min(size(img,dimIt),maxmax);
    
    range(:,dimIt) = linspace(minmin,maxmax,nCS);
end


padding = 30; % padding for the bounding box of the surface
% finding the maximum padding that we can put around the surface
% based on its extents
% for dim= 1 : ndims(img)
%     if ceil(range(end,dim)) + padding > size(img,dim)
%         padding= min(padding, size(img,dim)-ceil(range(end,dim)) );
%     end
%     if floor(range(1,dim)) - padding  < 1
%         padding= min(padding, floor(range(1,dim))-1 );
%     end    
%     
% end

surfExtents = { ( floor(range(1,1)) - padding ) : ( ceil(range(end,1)) + padding ); ...
    ( floor(range(1,2)) - padding ) : ( ceil(range(end,2)) + padding ); ...
    ( floor(range(1,3)) - padding ) : ( ceil(range(end,3)) + padding ); };
% cropping the image to the surface extents
imgC     = img(surfExtents{1} , surfExtents{2}, surfExtents{3} );
% and all the surfaces' vertices accordingly
for ss = 1 : length(vertices)
    vertices{ss} = [ vertices{ss}(:,1)-surfExtents{1}(1)+1 ,  vertices{ss}(:,2)-surfExtents{2}(1)+1,  vertices{ss}(:,3)-surfExtents{3}(1)+1 ];
end

% computing the scaling intensity limits
% based on just within the ROI or the whole image.

if scaleIntensitiesFlag
%    intyLimits = [ min(imgC(:)) max(imgC(:)) ];
    intyLimits = [ min(imgC(:)) (median(imgC(:))+3*std(imgC(:))) ];
%    intyLimits = [ min(imgC(:)) (max(imgC(:))-2*std(imgC(:))) ];

else
%    intyLimits = [ min(img(:)) max(img(:)) ];
    intyLimits = [ min(img(:)) (median(img(:))+3*std(img(:))) ];
%    intyLimits = [ min(img(:)) (max(img(:))-2*std(img(:))) ];

end

fHandles=gobjects(length(vertices),1);aHandles=cell(length(vertices),1);
if compareFlag % produce separate detailedChecks for each surface, but with exact same MRI slices
    for ss = 1:length(vertices)
        fHandles(ss) = figure('Visible','Off','Color','black','Position',...
            [100 100 5*(size(imgOrig,2)+size(imgOrig,3)) 2.5*(size(imgOrig,1)+size(imgOrig,3))]);
    end
else
    hFig=figure('Visible','Off','Color','black','Position',...
        [100 100 2.5*(size(imgOrig,2)+size(imgOrig,3)) 2.5*(size(imgOrig,1)+size(imgOrig,3))]);
    [ fHandles(:) ] = deal(hFig);
end

% deciding on whether to display surfaces horizantally/vertically to
% optimize zoom/stretch in lower-right portion
extentsInEachDim = range(end,:) - range(1,:);
hSurfRender=0.225;
%if ( extentsInEachDim(2) > extentsInEachDim(1) )
%    posSurf(1,:) = [ 0.5  0             0.5  hSurfRender];
%    posSurf(2,:) = [ 0.5  hSurfRender   0.5  hSurfRender];
%else
    posSurf(1,:) = [ 0.5        0  0.25  2*hSurfRender];
    posSurf(2,:) = [ 0.50+0.25  0  0.25  2*hSurfRender];
%end

%setviews = [ 970 -20; -90 270] ;
setviews = [ 0 0; 0 0 ] ; %this no longer contributes to anything; "side" changes the orientation


for ss = 1:length(vertices)
    side = 1 ; %is multipled by the verices to show the other side
    for vyuIt = 1 : size(setviews,1)
        set(0,'CurrentFigure',fHandles(ss));
        subplot('Position', posSurf(vyuIt,:));
%        trimesh(facesOrig{ss},vertices{ss}(:,1),vertices{ss}(:,2),vertices{ss}(:,3), ...
%            'facecolor',surfColor{ss},'edgecolor','none','facelighting','phong','BackFaceLighting','lit');
        trimesh(facesOrig{ss},side*verticesOrig{ss}(:,1),side*verticesOrig{ss}(:,2),verticesOrig{ss}(:,3), ...
            'facecolor',surfColor{ss},'edgecolor','none','facelighting','phong','BackFaceLighting','lit');
        material dull;
        axis off; axis image; hold on;
        camlight('headlight','infinite');
        view(setviews(vyuIt,:));
	side = (-1)*side;
    end
end
% adding lights at the camera - once
for ss = 1:length(vertices)
    % preventing adding many lights in the same plot
    if compareFlag > 0 || ss == 1
        set(0,'CurrentFigure',fHandles(ss));
        subplot('Position', posSurf(1,:));
        subplot('Position', posSurf(2,:));
    end
end

for dimIt =  1 : 3
    for rangeIt =  2 : nCS-1 % exluding the end slices
        
        sliceSelected = round( range(rangeIt,dimIt) ) - surfExtents{dimIt}(1) + 1;
        switch dimIt
            case 1
                imgSlice = squeeze( imgC( sliceSelected, :, :) ) ;
                imgAxes = [3,2];
                imgSlice = imgSlice(end:-1:1,:); % same as flipud
                % flip the first dimension in vertices accordingly - first
                % dim used will be 2, so flipping vertices in 2nd dim
                clear vertices2plot
                for ss = 1 : length(vertices)
                    vertices2plot{ss} = [ vertices{ss}(:,1) size(imgC,2)+1-vertices{ss}(:,2) vertices{ss}(:,3) ];
                end
                
            case 2
                imgSlice = squeeze( imgC( :, sliceSelected, :) );
                imgAxes = [3,1];
                vertices2plot = vertices;
            case 3
                imgSlice = squeeze( imgC( :, :, sliceSelected) );
                imgAxes = [2,1];
                vertices2plot = vertices;
        end
        
        % finding the slice number to be displayed on the quickcheck
        % in the original MR/surface space, and not the cropped space
        if dimIt == 1
            mrSliceNumberBrainworks = round(range(rangeIt,dimIt));
        else
            mrSliceNumberBrainworks = size(imgOrig,dimIt) - round(range(rangeIt,dimIt));
        end
        sliceNumDisplayStr = [ prefixSliceNum{dimIt} num2str(mrSliceNumberBrainworks) ];
        
        if compareFlag
            for ss = 1 : length(vertices2plot)
                set(0,'CurrentFigure',fHandles(ss));
                aHandles{ss,dimIt,rangeIt}=subplot('Position', subPlotPos( dimIt, rangeIt) ) ;
                imagesc(imgSlice, intyLimits); hold on;
                colormap gray; axis off; axis image;
                
                % displaying the slice number
                if IsDisplaySliceNumber
                    text(posSliceNum(1),posSliceNum(2),sliceNumDisplayStr,...
                        'Color','y','BackgroundColor','k', 'FontSize', fontSizeSliceNum);
                end
                
            end
        else
            set(0,'CurrentFigure',fHandles(1)); % identical fig. handles
            axisHandle=subplot('Position', subPlotPos( dimIt, rangeIt) ) ;
            [ aHandles{:,dimIt,rangeIt} ] = deal(axisHandle);
            imagesc(imgSlice, intyLimits); hold on;
            colormap gray; axis off; axis image;
            
            % displaying the slice number
            if IsDisplaySliceNumber
                text(posSliceNum(1),posSliceNum(2), sliceNumDisplayStr,...
                    'Color','y','BackgroundColor','k', 'FontSize', fontSizeSliceNum);
            end
        end
        
        
        planeNormal = accumarray(dimIt,1,[3,1])';
        planePoint  = accumarray(dimIt,sliceSelected, [3,1])';
        
        for ss = 1 : length(vertices2plot)
            [segmentCell, segmentVertices] = extractSurfacePlaneIntersectionSpline(vertices2plot{ss}, facesOrig{ss}, planeNormal,planePoint);
            for sit = 1:length(segmentCell)
                connectedSpline = [ segmentCell{sit}(1,:), segmentCell{sit}(2,end) ];
                %                 set(0,'CurrentFigure',fHandles(ss));
                plot(aHandles{ss,dimIt,rangeIt},segmentVertices(connectedSpline,imgAxes(1)),segmentVertices(connectedSpline,imgAxes(2)),'color',surfColor{ss}, 'LineWidth',surfOutLineWidth);
            end
        end
        
    end % rangeIt
    
end % dimIt


%%%%%%---------------------------------------- ANNOTATION ----------------------------------------

% annotFlag == 0 --> no path/legends displayed
% annotFlag == 1 --> only legends is displayed
% annotFlag == 2 --> both are displayed

% removes some characters in the middle and adds (...) so it fits in withing the width
if length(pathOfSubject) > 120
    centerTrim = @(str,CTR,RemChars) ( [ str( 1: (CTR-3-RemChars) ) '(...)'  str(CTR+2+RemChars : length(str)) ]  );
    strCenter = @(str) round(length(str)/2);
    halfNumberExtraChars = @(str) round((length(str)-120)/2) ; % 120 characters would fit properly within the width of the figure
    pathOfSubject = centerTrim(pathOfSubject, strCenter(pathOfSubject), halfNumberExtraChars(pathOfSubject) );
end

if compareFlag == 0 % all-in-one case

    if annotFlag ~= 0 % when it is 1 or 2
        
        set(0,'CurrentFigure',fHandles(1)); hold on;
        legends  = cellfun( @trimext, legends, 'UniformOutput', false );

        if annotFlag == 2
            subplot('Position',annotPathPos , 'Color', 'k' ); axis off;
            text(0.05,0.5,[ ' Subject: ' pathOfSubject ],'Interpreter','none','Color','g','BackgroundColor','k','fontsize',fontSize,'horizontalAlignment','left');
        end
        
        % making TEX format string to display the legends
        texFormatStr=sprintf('\fontsize{%d}',fontSize);
        for ll = 1 : length(legends)
            surfColorStr = strrep(strrep(strrep(mat2str(surfColor{ll}),' ',','),'[',''),']','');
            texFormatStr=[ texFormatStr '\color[rgb]{' surfColorStr '}' legends{ll} ' ' ]; %#ok<*AGROW>
        end
        texFormatStr = strrep(texFormatStr,'_','-'); % making sure TEX sub/super scripts are not interpreted
        texFormatStr = strrep(texFormatStr,'^','-');
        subplot('Position',annotLegdPos , 'Color', 'k' ); hold on; axis off;
        text( 0,0.5,texFormatStr,'BackgroundColor','k','horizontalAlignment','left','fontsize',fontSize);
        
    end  % if annotFlag ~= 0
    
else % otherwise put the legends on the respective surfaces
    
    if annotFlag ~= 0 % when it is 1 or 2
        
        for ss = 1 : length(vertices)
            set(0,'CurrentFigure',fHandles(ss)); hold on;
            legends  = cellfun( @trimext, legends, 'UniformOutput', false );

            if annotFlag == 2
                subplot('Position', annotPathPos, 'Color', 'k' ); axis off;
                text(0.05,0.5,[ ' Subject: ' pathOfSubject ],'Interpreter','none','Color','g','BackgroundColor','k','fontsize',fontSize,'horizontalAlignment','left');
            end
            surfColorStr = strrep(strrep(strrep(mat2str(surfColor{ss}),' ',','),'[',''),']','');
            texFormatStr = [ sprintf('\fontsize{%d}',fontSize) '\color[rgb]{' surfColorStr '}' legends{ss} ' ' ];
            texFormatStr = strrep(texFormatStr,'_','-');
            texFormatStr = strrep(texFormatStr,'^','-');
            subplot('Position', annotLegdPos, 'Color', 'k' ); hold on; axis off;
            text( 0,0.5,texFormatStr,'BackgroundColor','k','horizontalAlignment','left','fontsize',fontSize);
        end
        
    end % if annotFlag ~= 0

end % if compareFlag == 0

end %%%%----------------------------------------


function pos = subPlotPos(dimIt, rangeIt)
% to decide the positions of the many subplots in the quickcheck

desgBase = [ 0 0; 0.5 0.55; 0 0.55];
% bounding box params for a 4-quad 3x3 grid
% wBB = 0.16; hBB = 0.15; % without slice numbers

wBB = 0.16; hBB = 0.15; % with slice numbers

base = desgBase(dimIt, :);

%-% Pattern: [ 1 2 3; 4 5 6; 7 8 9]
w = mod(rangeIt-2, 3)*wBB;
h = abs( floor((rangeIt-2)/3) - 2 )*hBB;
pos = [ base+[w h] wBB hBB ];

end

%{
function longClr = longCode( clr )


switch clr
    case 'y'
        longClr ='yellow';
    case 'm'
        longClr ='magenta';
    case 'c'
        longClr ='cyan';
    case 'r'
        longClr ='red';
    case 'g'
        longClr ='green';
    case 'b'
        longClr ='blue';
    case 'w'
        longClr ='white';
    case 'k'
        longClr ='black';
    otherwise
        warning('Quickcheck:invalidColorArg','Supplied Color argument is not valid - using green instead');
        longClr='green';
end

end
%}

