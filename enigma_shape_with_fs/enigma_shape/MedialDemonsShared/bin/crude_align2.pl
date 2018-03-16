###/usr/bin/perl -w

use File::Basename;
use Math::Complex;


if($#ARGV < 3)
{
	die("usage: perl crude_align2.pl [bin_dir] [atlas_dir] [input_labels].img [output_transform].xfm");
}


#ARGS

#paths
$bin_dir = $ARGV[0];
$atlas_dir = $ARGV[1];

#inputs
$input_labels = $ARGV[2];

#outputs
$output_transform = $ARGV[3];
$out_flip  = $ARGV[4];



#setting paths, filenames

#$working_dir =~ s/\s*$//;
#my($filename, $directories, $suffix) = fileparse($mesh_file,qr/\.[^.]*/);
#$mesh_name = $working_dir;
#$mesh_name = $mesh_name.sprintf("/%s",$filename);
#$mesh_name =~ s/\s*$//;


#$Cmd_str = "mkdir $working_dir";
#print "$Cmd_str\n";
#system $Cmd_str;



#main commands start here


$Cmd_str = single_line("$bin_dir/ccbbm -align_ROIs $input_labels ${atlas_dir}/atlas_11.m ${atlas_dir}/atlas_17.m 
${atlas_dir}/atlas_50.m ${atlas_dir}/atlas_53.m ${atlas_dir}/atlas_10.m ${atlas_dir}/atlas_12.m ${atlas_dir}/atlas_13.m 
${atlas_dir}/atlas_18.m ${atlas_dir}/atlas_26.m ${atlas_dir}/atlas_49.m ${atlas_dir}/atlas_51.m ${atlas_dir}/atlas_52.m 
${atlas_dir}/atlas_54.m ${atlas_dir}/atlas_58.m 11 17 50 53 10 12 13 18 26 49 51 52 54 58 $output_transform");
print "$Cmd_str\n";
system $Cmd_str;



sub single_line {
 my @strings = @_;
 foreach ( @strings ) {
 s/\n/ /g;
 s/\r/ /g;
 }
 return wantarray? @strings : $strings[0];
}