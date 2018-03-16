###/usr/bin/perl -w

use File::Basename;
use Math::Complex;


if($#ARGV < 8)
{
	die(single_line("usage: perl demons_sphere_reg2.pl [bin_dir] [working_dir] [bandwidth](int, power of 2) 
	[sampled target].m [sampled template].m [target curve].ucf [template curve].ucf [initial warp].m
	[spherical warp output].m"));
}

#params

$sigma_att = 5e-3;
$sigma_dem = 3e-2;
$sigma_diff = 3e-3;
$step = 0.03;
$iters = 100;
$tol = 1e-3;
$GOF_wt = 10.0;
$thick_wt = 0.01;

#ARGS

#paths
$bin_dir = $ARGV[0];
$working_dir = $ARGV[1];

#inputs
$bw = $ARGV[2];
$target = $ARGV[3];
$template = $ARGV[4];

$target_curve = $ARGV[5];
$template_curve = $ARGV[6];

$init_warp = $ARGV[7];

#outputs
$warp = $ARGV[8];


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


$Cmd_str = "$bin_dir/ccbbm -store_att_curv ${template_name}_tar_cl.m ${template_name}_tar_mean.raw ${template_name}_tar_gauss2.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -store_att_curv ${template_name}_tmp_cl.m ${template_name}_tmp_mean.raw ${template_name}_tmp_gauss2.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -curve_function ${template_name}_tar_cl.m $target_curve ${template_name}_tar_GOF.raw ${template_name}_tar_thick.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -curve_function ${template_name}_tmp_cl.m $template_curve ${template_name}_tmp_GOF.raw ${template_name}_tmp_thick.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -gausssmooth_attribute2 $bw ${template_name}_tar_mean.raw $sigma_att ${template_name}_tar_mean.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -gausssmooth_attribute2 $bw ${template_name}_tar_thick.raw $sigma_att ${template_name}_tar_thick.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -gausssmooth_attribute2 $bw ${template_name}_tmp_mean.raw $sigma_att ${template_name}_tmp_mean.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -gausssmooth_attribute2 $bw ${template_name}_tmp_thick.raw $sigma_att ${template_name}_tmp_thick.raw";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = single_line("$bin_dir/ccbbm -Demons_VSH2 64 $sigma_dem ${template_name}_tar_mean.raw ${template_name}_tmp_mean.raw 
			$step $iters $tol ${template_name}_dem_sphere.m $warp -prev_warp $init_warp -diffeo -symm 
			-sigma_v $sigma_diff -tar_atts ${template_name}_tar_GOF.raw ${template_name}_tar_thick.raw 
			-tmp_atts ${template_name}_tmp_GOF.raw ${template_name}_tmp_thick.raw -att_wts $GOF_wt $thick_wt");
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
