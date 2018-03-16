function multiSurfaceOverlayOnMri_batch(surfNames, subjlist, imgNames, ...
    outputNames, surfColor, prnDriver, overlayFlag, annotFlag,...
    scaleIntensitiesFlag, IsDisplaySliceNumber)


for it = 1:length(subjlist)  
    vertices = cell(length(surfNames));faces = cell(length(surfNames));
    ssList = [];
    for ss = 1 : length(surfNames)
	try
            [nvertex, ntris, nconns, triloc, tris] = loadbyu( fullfile(subjlist{it},surfNames{ss}) );
            vertices{ss} = triloc;
            faces{ss} = tris;
            ssList = [ssList, ss];
	catch e
	    fprintf('Failed to load byu %s for %s\n', surfNames{ss}, subjlist{it});
	end
    end

    try
        switch fileext(imgNames{it})
            case '.img'
                img = readanalyze(imgNames{it});
            case '.mgz'
                img = mialReadMRI(imgNames{it});
                img = img.vol;
            otherwise
                error('Only .img/.mgz files are supported');
        end
        
        
        switch overlayFlag
            case 0 % all-in-one-figure, common bounding box.
                fHandles = multiSurfaceOverlayDetailedCheck(img, vertices, faces, surfColor, subjlist{it}, surfNames, 0, annotFlag, scaleIntensitiesFlag, IsDisplaySliceNumber);
            case 1 % compare - separate figures, common bounding box- on same slices.
                % Extents in each figure decided by all the surfaces
                fHandles = multiSurfaceOverlayDetailedCheck(img, vertices, faces, surfColor, subjlist{it}, surfNames, 1, annotFlag, scaleIntensitiesFlag, IsDisplaySliceNumber);
            case 2 % separate - separate figures, separate bounding box
                % Extents in each figure decided by respective surfaces
                fHandles=zeros(size(surfNames),'uint8');
                for ss = ssList
                    fHandles(ss) = multiSurfaceOverlayDetailedCheck(img, vertices(ss), faces(ss), ...
                        surfColor(ss), subjlist{it}, surfNames(ss), 0, annotFlag, scaleIntensitiesFlag, IsDisplaySliceNumber);
                end
            otherwise
                error('Invalid overlayflag - must be 0,1 or 2.');
                
        end
        
        if ~overlayFlag
            set(fHandles(1), 'InvertHardCopy','off');
            set(0,'CurrentFigure',fHandles(1));
            print(prnDriver,'-r250',[outputNames{it} '.' prnDriver(3:end)]);
            close(gcf);
        else
            for ss = ssList
                set(0,'CurrentFigure',fHandles(ss));
                set(fHandles(ss), 'InvertHardCopy','off');
                print(prnDriver,'-r250',[outputNames{it} '_' rmext(surfNames{ss}) '.' prnDriver(3:end)]);
                close(gcf);
            end
        end
        
    catch e
        fprintf('\nFailed to quickcheck one/all surfaces for %s\n',subjlist{it});
        disp(e.message)
    end

disp(' ');

end
