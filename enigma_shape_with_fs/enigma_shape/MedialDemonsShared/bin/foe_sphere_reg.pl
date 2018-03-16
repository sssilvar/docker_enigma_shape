###/usr/bin/perl -w

use File::Basename;
use Math::Complex;


if($#ARGV < 4)
{
	die("usage: perl rigid_sphere_reg.pl [bin_dir] [working_dir] [bandwidth](int, power of 2) 
	[sampled target].m [template].m [registered sampled template].m [rotated template sphere].m");
}

#params

$tao_toler = 1e-8;
$area_weight = 3;
$smoothing_weights = 0.2;
$sigma = 1e-4;

#ARGS

#paths
$bin_dir = $ARGV[0];
$working_dir = $ARGV[1];

#inputs
$bw = $ARGV[2];
$target = $ARGV[3];
$template = $ARGV[4];

#outputs
$registered_out = $ARGV[5];
$rotated_sphere_out = $ARGV[6];

#setting paths, filenames

$working_dir =~ s/\s*$//;
my($filename, $directories, $suffix) = fileparse($template,qr/\.[^.]*/);
$template_name = $working_dir;
$template_name = $template_name.sprintf("/%s",$filename);
$template_name =~ s/\s*$//;


$Cmd_str = "mkdir $working_dir";
print "$Cmd_str\n";
system $Cmd_str;



#main commands start here (not done yet)


#$Cmd_str = "perl $bin_dir/sphere_param_w_init.pl $bin_dir $working_dir $bw $template $rotated_sphere_out $registered_out";
$Cmd_str = "perl $bin_dir/sphere_param_w_init_smart.pl $bin_dir $working_dir $bw $template $rotated_sphere_out $registered_out";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -foeloc $bw $target $registered_out $registered_out ${template_name}_angles.txt";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -rotate $rotated_sphere_out ${template_name}_angles.txt $rotated_sphere_out";
print "$Cmd_str\n";
system $Cmd_str;
