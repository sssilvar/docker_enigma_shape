###/usr/bin/perl -w

use File::Basename;
use Math::Complex;


if($#ARGV < 7)
{
	die(single_line("usage: perl sample_by_warp.pl [bin_dir] [working_dir] [bandwidth](int, power of 2) 
	[mesh input].m [sphere input].m [target sphere input].m [warp input].m [sampled output].m"));
}

#params



#ARGS

#paths
$bin_dir = $ARGV[0];
$working_dir = $ARGV[1];

#inputs
$bw = $ARGV[2];
$mesh = $ARGV[3];
$sphere = $ARGV[4];
$tar_sphere = $ARGV[5];
$warp = $ARGV[6];

#outputs
$sampled = $ARGV[7];


#setting paths, filenames

$working_dir =~ s/\s*$//;
my($filename, $directories, $suffix) = fileparse($warp,qr/\.[^.]*/);
$warp_name = $working_dir;
$warp_name = $warp_name.sprintf("/%s",$filename);
$warp_name =~ s/\s*$//;


$Cmd_str = "mkdir $working_dir";
print "$Cmd_str\n";
system $Cmd_str;



#main commands start here 


$Cmd_str = "$bin_dir/ccbbm -apply_sphere_warp_arcsin2 $bw $sphere $warp ${warp_name}_warped_sphere.m";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -fastsampling ${warp_name}_warped_sphere.m $tar_sphere $mesh $sampled";
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
