function [segmentCell, vertices, coplanarTriangles] = extractSurfacePlaneIntersectionSpline(pts, tri, planeNormal, planePoint)
% Finds the intersection of a surface with a plane
% [segmentCell, vertices, coplanarTriangles] = extractSurfacePlaneIntersectionSpline(pts, tri, planeNormal, planePoint)
% Finds the intersection of a surface with a plane. Returns
% pts - Mx3 matrix of vertex coordinates
% tri - Mx3 matrix of indices into the pts matrix for the corners of each triangle
% planeNormal - 1x3 vector holding the normal to the plane
% planePoint - 1x3 vector holding any point on the plane
% segmentCell - cell containing a number of adjoined segments listed by index into the vertices matrix
% vertices - matrix holding vertex coordinates for the spline and coplanar triangles
% coplanarTriangles - Nx3 matrix holding row indices into the vertices matrix, 
%                     yielding triangles in surface which are coplanar to
%                     the plane. These cannot be properly represented as a
%                     spline, but are part of the surface plane
%                     intersection

    segments = [];
    signedDist = dot(pts-repmat(planePoint,size(pts,1),1), repmat(planeNormal,size(pts,1),1),2);
    vertSignedDist = signedDist(tri);
    inPlane = vertSignedDist==0;
    numInPlane = sum(inPlane,2);
    anyInPlane = any(inPlane,2);
    outPlanePos = vertSignedDist>0;
    numOutPlanePos = sum(outPlanePos,2);
    outPlaneNeg = vertSignedDist<0;
    numOutPlaneNeg = sum(outPlaneNeg,2);

    coplanar = all(inPlane,2);
    
    %Get segments made from coplanar triangle edges 
    bEdgeOnPlane = numInPlane==2;
    edgeOnPlane = tri(find(bEdgeOnPlane),:)';
    segments1 = reshape(pts(edgeOnPlane(signedDist(tri(find(bEdgeOnPlane),:))'==0),:),2,[],3);
    
    %Get segments made from 1 edge and one vertex intersecting plane
    bVertexOnPlane = (numInPlane==1) & (numOutPlanePos==1);
    vertexOnPlane = tri(find(bVertexOnPlane) ,:)';
    intersectingVertex=vertexOnPlane( (signedDist(tri(find(bVertexOnPlane),:))'==0));
    opposingSegments =  vertexOnPlane(~(signedDist(tri(find(bVertexOnPlane),:))'==0));
    segments2 = permute( ...
        cat(3,pts(intersectingVertex(:,:),:), ... %vertex intersecting and interpolated point
        pts(opposingSegments(1:2:end),:) ... % one end of segment
        + (pts(opposingSegments(2:2:end),:) - pts(opposingSegments(1:2:end),:)) ... % plus the difference vector
        .* repmat(-signedDist(opposingSegments(1:2:end))./(signedDist(opposingSegments(2:2:end))-signedDist(opposingSegments(1:2:end))),1,3)... % scaled by the relative distances from the plane.
        ), ...
        [3,1,2]);
    
%     reshape(pts(,:),2,[],3)
    %Get segments made from 2 edges intersecting plane
    bFaceOnPlaneOnePointPositive = ~anyInPlane & (numOutPlanePos==1);
    faceOnPlaneOnePointPositive = tri(find(bFaceOnPlaneOnePointPositive),:)';
    bFaceOnPlaneOnePointNegative = ~anyInPlane & (numOutPlaneNeg==1);
    faceOnPlaneOnePointNegative = tri(find(bFaceOnPlaneOnePointNegative),:)';
    onePoint = [faceOnPlaneOnePointPositive( (signedDist(tri(find(bFaceOnPlaneOnePointPositive),:))'>0));...
                faceOnPlaneOnePointNegative( (signedDist(tri(find(bFaceOnPlaneOnePointNegative),:))'<0))];
    twoPoint = [faceOnPlaneOnePointPositive( (signedDist(tri(find(bFaceOnPlaneOnePointPositive),:))'<0));...
                faceOnPlaneOnePointNegative( (signedDist(tri(find(bFaceOnPlaneOnePointNegative),:))'>0))];
    segments3 = permute( ...
        cat(3,... % interpolated point
        pts(onePoint(:),:) ... % one end of segment
        + (pts(twoPoint(1:2:end),:) - pts(onePoint(:),:)) ... % plus the difference vector
        .* repmat(-signedDist(onePoint(:))./(signedDist(twoPoint(1:2:end))-signedDist(onePoint(:))),1,3)... % scaled by the relative distances from the plane.
        , ... % and another interpolated point
        pts(onePoint(:),:) ... % one end of segment
        + (pts(twoPoint(2:2:end),:) - pts(onePoint(:),:)) ... % plus the difference vector
        .* repmat(-signedDist(onePoint(:))./(signedDist(twoPoint(2:2:end))-signedDist(onePoint(:))),1,3)... % scaled by the relative distances from the plane.
        ), ...
        [3,1,2]);

    segments = [segments1,segments2,segments3];

    %reorient segments so that first coord is lexicographically first
    wrongOrder = ...
        find((segments(1,:,1) <  segments(2,:,1)) | ...
            ((segments(1,:,1) == segments(2,:,1)) & (segments(1,:,2) <  segments(2,:,2))) | ...
            ((segments(1,:,1) == segments(2,:,1)) & (segments(1,:,2) == segments(2,:,2)) & (segments(1,:,3) < segments(2,:,3))) );
    segments(:,wrongOrder,:) = segments([2,1],wrongOrder,:); 
    %remove duplicate segments
    segments = permute(reshape(unique(reshape(permute(segments,[2,1,3]),[],6),'rows'),[],2,3),[2,1,3]);

    if 0 %debug code
        trimesh(tri(find(any(abs(vertSignedDist)<10,2)),:),pts(:,1),pts(:,2),pts(:,3));
        hold on;
        normalLine = [planePoint;planePoint+planeNormal];
        line(normalLine(:,1),normalLine(:,2),normalLine(:,3))
    end

    [segmentCell, vertices] = reformatSplines(segments);
    
    ptsNeededForCoplanarTriangles = pts(tri(coplanar,:),:);
    [verticesTri, map, map2] = unique(ptsNeededForCoplanarTriangles,'rows'); 
    coplanarTriangles = size(vertices,1) + reshape(map2, [],3);
    vertices = [vertices;verticesTri];
end

function [newSegments, verts] = reformatSplines(segments)
% we want to end up with groups of segments attached end to end
% build adjacency struct
% walk adjacency struct

    % get vertices
    endpoints = reshape(segments,[],3);
    % do some rounding allow equality of floats
    endpoints = round(1e10*endpoints)/1e10;
    [verts,tmp,index] = unique(endpoints,'rows');
    index = reshape(index,2,[]);

    % used fills up with ones as the segments are added to newSegments
    % segs holds the indices of the segments being used in order
    % newSegments holds all the segment end points in order for each set of
    %       segments
    used = zeros(1,size(segments,2));
    newSegments = {};
    while 1
        segs = [];
        
        newSeg = find(used==0,1,'first');
        if isempty(newSeg)
            break
        end
        segs(end+1) = newSeg;
        newSegments{length(newSegments)+1}=index(:,newSeg);
        used(segs(end))=1;
        nextvertex = index(2,segs(end));
        while 1
            newSeg=find((index(1,:)==nextvertex | index(2,:)==nextvertex) & ~used,1,'first');
            if isempty(newSeg)
                break
            end
            segs(end+1) = newSeg;
            if index(1,newSeg) == nextvertex
               newSegments{end} = [newSegments{end},index(:,newSeg)];
            else
               newSegments{end} = [newSegments{end},index([2,1],newSeg)];
            end
            used(segs(end))=1;
            nextvertex = newSegments{end}(2,end);
        end
    end
end