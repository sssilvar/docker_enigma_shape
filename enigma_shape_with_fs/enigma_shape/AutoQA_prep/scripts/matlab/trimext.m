function [ fullPathFileNameWithoutExt  baseNameFile path ext ] = trimext( fullPathToFile )

[path, baseNameFile, ext ] = fileparts(fullPathToFile) ;

if isempty( path ); prefix = '';
else prefix = [  path filesep ]; end

fullPathFileNameWithoutExt = [ prefix baseNameFile ];
