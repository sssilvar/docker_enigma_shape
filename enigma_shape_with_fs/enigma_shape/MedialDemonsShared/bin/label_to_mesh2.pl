###/usr/bin/perl -w

use File::Basename;
use Math::Complex;



if($#ARGV < 5)
{
	die("usage: perl label_to_mesh2.pl [bin_dir] [working_dir] [freesurfer bin] [aseg_file].aseg [label_id](int) [mesh_output].m [ana mask].img");
}

#params

$final_face_num = 5000;
$smoothing_iters = 3;
$smoothing_weights = 0.2;

#ARGS

#paths
$bin_dir = $ARGV[0];
$working_dir = $ARGV[1];
$freesurfer_bin = $ARGV[2];

#inputs
$aseg_file = $ARGV[3];
$label_id = $ARGV[4];

#outputs
$mesh_out = $ARGV[5];
$ana_mask = $ARGV[6];


#setting paths, filenames

$working_dir =~ s/\s*$//;
my($filename, $directories, $suffix) = fileparse($aseg_file,qr/\.[^.]*/);
$ana_name = $working_dir;
$ana_name = $ana_name.sprintf("/%s",$filename);
$ana_name =~ s/\s*$//;


$Cmd_str = "mkdir $working_dir";
print "$Cmd_str\n";
system $Cmd_str;



#main commands start here

$Cmd_str = "$freesurfer_bin/mri_convert $aseg_file ${ana_mask}";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/MeshfromAnalyze -p $smoothing_weights -m $smoothing_weights -d 1 -e -b -1 40 -M $label_id ${ana_mask} ${ana_name}_MC.m ${ana_name}_LS.img";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -simplify ${ana_name}_MC.m $final_face_num ${ana_name}_QEM.m";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -subdivision  ${ana_name}_QEM.m ${ana_name}_LAP.m $smoothing_iters";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -reset_orig_from_subdivision ${ana_name}_QEM.m ${ana_name}_LAP.m $mesh_out";
print "$Cmd_str\n";
system $Cmd_str;

