###/usr/bin/perl -w

use File::Basename;
use Math::Complex;


if($#ARGV < 4)
{
	die("usage: perl sphere_param.pl [bin_dir] [working_dir]  [input mesh].m [input atlas mesh].m [TBM output].raw");
}

#params

$smoothing_iters = 20;

#ARGS

#paths
$bin_dir = $ARGV[0];
$working_dir = $ARGV[1];

#inputs
$mesh_file = $ARGV[2];
$atlas_mesh = $ARGV[3];

#outputs
$TBM_out = $ARGV[4];


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


$Cmd_str = "${bin_dir}/ccbbm -store_att_area $mesh_file ${working_dir}/area.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "${bin_dir}/ccbbm -store_att_area $atlas_mesh ${working_dir}/atlas_area.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/raw_operations -divide -float ${working_dir}/area.raw ${working_dir}/atlas_area.raw ${working_dir}/ratio_area.raw";
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = "$bin_dir/raw_operations -log -float  ${working_dir}/ratio_area.raw ${working_dir}/Log.raw";
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = "${bin_dir}/ccbbm -laplacian_smooth_attribute $atlas_mesh ${working_dir}/Log.raw $TBM_out $smoothing_iters";
print "$Cmd_str\n";
system $Cmd_str;
