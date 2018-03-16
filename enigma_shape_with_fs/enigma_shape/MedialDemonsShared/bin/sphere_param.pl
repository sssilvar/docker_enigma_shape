###/usr/bin/perl -w

use File::Basename;
use Math::Complex;


if($#ARGV < 4)
{
	die("usage: perl sphere_param.pl [bin_dir] [working_dir] [bandwidth](int, power of 2) [input mesh].m [spherical mesh output].m [sampled mesh output].m");
}

#params

#$tao_toler = 1e-8;
#$area_weight = 3;

$dir_weight = 3;
$step_size = 2e-2;

$smoothing_weights = 0.2;
$sigma = 1e-4;

#ARGS

#paths
$bin_dir = $ARGV[0];
$working_dir = $ARGV[1];

#inputs
$bw = $ARGV[2];
$mesh_file = $ARGV[3];

#outputs
$sphere_out = $ARGV[4];
$sampled_out = $ARGV[5];


#setting paths, filenames

$working_dir =~ s/\s*$//;
my($filename, $directories, $suffix) = fileparse($mesh_file,qr/\.[^.]*/);
$mesh_name = $working_dir;
$mesh_name = $mesh_name.sprintf("/%s",$filename);
$mesh_name =~ s/\s*$//;


$Cmd_str = "mkdir $working_dir";
print "$Cmd_str\n";
system $Cmd_str;



#main commands start here


$Cmd_str = "$bin_dir/ccbbm -spheremaptest $mesh_file $sphere_out $dir_weight $step_size ";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -regularsample $bw $sphere_out $mesh_file $sampled_out";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -gausssmooth_shape $bw $sampled_out $sigma $sampled_out";
print "$Cmd_str\n";
system $Cmd_str;
