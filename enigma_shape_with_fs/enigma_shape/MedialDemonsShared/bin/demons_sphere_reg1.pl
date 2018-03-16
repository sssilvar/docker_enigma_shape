###/usr/bin/perl -w

use File::Basename;
use Math::Complex;


if($#ARGV < 4)
{
	die(single_line("usage: perl rigid_sphere_reg.pl [bin_dir] [working_dir] [bandwidth](int, power of 2) 
	[sampled target].m [sampled template].m [spherical warp output].m"));
}

#params

$sigma_att = 5e-3;
$sigma_dem = 3e-2;
$sigma_diff = 3e-3;
$step = 0.03;
$iters = 100;
$tol = 1e-3;
$gauss_wt = 0.3;

#ARGS

#paths
$bin_dir = $ARGV[0];
$working_dir = $ARGV[1];

#inputs
$bw = $ARGV[2];
$target = $ARGV[3];
$template = $ARGV[4];

#outputs
$warp = $ARGV[5];


#setting paths, filenames

$working_dir =~ s/\s*$//;
my($filename, $directories, $suffix) = fileparse($template,qr/\.[^.]*/);
$template_name = $working_dir;
$template_name = $template_name.sprintf("/%s",$filename);
$template_name =~ s/\s*$//;


$Cmd_str = "mkdir $working_dir";
print "$Cmd_str\n";
system $Cmd_str;



#main commands start here 


$Cmd_str = "$bin_dir/ccbbm -close_boundaries $target ${template_name}_tar_cl.m";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -close_boundaries $template ${template_name}_tmp_cl.m";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -store_att_curv ${template_name}_tar_cl.m ${template_name}_tar_mean.raw ${template_name}_tar_gauss.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -store_att_curv ${template_name}_tmp_cl.m ${template_name}_tmp_mean.raw ${template_name}_tmp_gauss.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -gausssmooth_attribute2 $bw ${template_name}_tar_mean.raw $sigma_att ${template_name}_tar_mean.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -gausssmooth_attribute2 $bw ${template_name}_tar_gauss.raw $sigma_att ${template_name}_tar_gauss.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -gausssmooth_attribute2 $bw ${template_name}_tmp_mean.raw $sigma_att ${template_name}_tmp_mean.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -gausssmooth_attribute2 $bw ${template_name}_tmp_gauss.raw $sigma_att ${template_name}_tmp_gauss.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = single_line("$bin_dir/ccbbm -Demons_VSH2 64 $sigma_dem ${template_name}_tar_mean.raw ${template_name}_tmp_mean.raw 
			$step $iters $tol ${template_name}_dem_sphere.m $warp -diffeo -symm -sigma_v $sigma_diff -tar_atts 
			${template_name}_tar_gauss.raw -tmp_atts ${template_name}_tmp_gauss.raw -att_wts $gauss_wt");
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
