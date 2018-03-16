%function [nvertex, ntris, nconns, triloc, tris] = loadbyu(byufile);
%
% Function:
%           read *.byu file (just has one part)
% Input:
%          byufile  - name of *.byu
% Output:
%          nvertex   number of vertices
%          ntris     number of triangles
%          nconns    number of connectivity entries
%          triloc    matrix (#vertices,3) coordinates
%          tris      matric (#triangles,3) verticex in each triangle
% Anqi Qiu
% 05/22/2004


function [nvertex, ntris, nconns, triloc, tris] = loadbyu(byufile);

fid = fopen(byufile,'r');
if (fid<0)
    disp('Error! Cannot open the file!');
    return;
end;

npart = fscanf(fid, '%d', 1);

%May want to add else if there are more than one surface
%if (npart == 1)
    nvertex = fscanf(fid, '%d', 1);
    ntris = fscanf(fid, '%d', 1);
    nconns = fscanf(fid, '%d', 1);
    a = fscanf(fid,'%d', 2);
    %else
   % return;
   %end

%read the coordinates of each vertex
[triloc, Count] = fscanf(fid, '%f ', [3,nvertex]);
if (Count~=3*nvertex)
    disp('Reading Error! ');
    return;
end
triloc = triloc';

%read the triangle structure
[tris, Count] = fscanf(fid, '%d', [3,ntris]);
if (Count~=3*ntris)
    disp('Reading Error! ');
    return;
end
tris = tris';
tris(:,3) = -tris(:,3);

fclose(fid);

