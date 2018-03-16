###/usr/bin/perl -w

use File::Basename;
use Math::Complex;


if($#ARGV < 3)
{
	die("usage: perl rename_wth_int2.pl [output file] [out path] [out name] [int]");
}


#ARGS

#inputs
$file = $ARGV[0];
$path = $ARGV[1];
$name = $ARGV[2];
$int = $ARGV[3];



#setting paths, filenames


$path =~ s/\s*$//;
$name =~ s/\s*$//;

my($in_name, $in_dir, $in_suffix) = fileparse($file,qr/\.[^.]*/);



$Cmd_str = "mkdir -p $path";
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = "cp ${path}/${name}_${int}${in_suffix} $file";
print "$Cmd_str\n";
system $Cmd_str;



