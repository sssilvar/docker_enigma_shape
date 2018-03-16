###/usr/bin/perl -w

use File::Basename;
use Math::Complex;


if($#ARGV < 4)
{
	die(single_line("usage: perl Medial_Demons2.pl [FreeSurfer aseg file] [label id (int)] 
	[output directory] [medial directory] [FreeSurfer program directory]"));
}

#params

$bw = 64;


#paths
$output_dir = $ARGV[2];
$medial_dir = $ARGV[3];
$freesurfer_bin = $ARGV[4];


#ARGS

#inputs
$aseg = $ARGV[0];
$label_id = $ARGV[1];





#setting paths, filenames


$medial_dir =~ s/\s*$//;
$bin_dir = $medial_dir;
$bin_dir = $bin_dir.sprintf("/bin");
$bin_dir =~ s/\s*$//;

$atlas_dir = $medial_dir;
$atlas_dir = $atlas_dir.sprintf("/atlas");
$atlas_dir =~ s/\s*$//;

my($aseg_file, $aseg_dir, $aseg_suffix) = fileparse($aseg,qr/\.[^.]*/);
$working_dir = $aseg_dir;
$working_dir = $working_dir.sprintf("%s_%i",$aseg_file,$label_id);
$working_dir =~ s/\s*$//;

$FS_convert  = "${freesurfer_bin}/mri_convert";

unless (-e $FS_convert) { die("File $FS_convert Doesn't Exist!"); }

$Cmd_str = "mkdir $working_dir";
print "$Cmd_str\n";
system $Cmd_str;


$output_dir2 = $output_dir;
$output_dir2 =~ s/\s*$//;

$Cmd_str = "mkdir -p $output_dir2";
print "$Cmd_str\n";
system $Cmd_str;



#outputs

$resliced = "${working_dir}/resliced.m";
$curve = "${working_dir}/curve.ucf";
$thick = "${working_dir}/thick.raw";
$TBM = "${working_dir}/LogJacs.raw";



#main commands start here 


$Cmd_str = "perl $bin_dir/label_to_mesh2.pl $bin_dir $working_dir $freesurfer_bin $aseg $label_id ${working_dir}/mesh.m ${working_dir}/ana2.img";
print "$Cmd_str\n";
system $Cmd_str;


##################################
###### labels crude alignment ####
##################################

$Cmd_str = "perl $bin_dir/crude_align2.pl $bin_dir $atlas_dir ${working_dir}/ana2.img ${working_dir}/trans.txt";
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = "$bin_dir/ccbbm -transform ${atlas_dir}/sphere_${label_id}.m ${working_dir}/trans.txt ${working_dir}/sphere_ATL_rot.m";
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = "$bin_dir/ccbbm -fix_normals ${working_dir}/sphere_ATL_rot.m ${working_dir}/sphere_ATL_rot.m";
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -transform ${atlas_dir}/atlas_${label_id}.m ${working_dir}/trans.txt ${working_dir}/atlas_ATL_rot.m";
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = "$bin_dir/ccbbm -fix_normals ${working_dir}/atlas_ATL_rot.m ${working_dir}/atlas_ATL_rot.m";
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = "$bin_dir/ccbbm -transform_ucf  ${atlas_dir}/curve_${label_id}.ucf ${working_dir}/trans.txt ${working_dir}/curve_tar_rot.ucf";
print "$Cmd_str\n";
system $Cmd_str;



##################################
### END labels crude alignment ###
##################################



$Cmd_str = "$bin_dir/ccbbm -regularsample $bw ${working_dir}/sphere_ATL_rot.m ${working_dir}/atlas_ATL_rot.m ${working_dir}/sampled_atlas.m";
print "$Cmd_str\n";
system $Cmd_str;



##################################
###### rescale sampled atlas ##### only for registration purposes
##################################

$Cmd_str = "$bin_dir/ccbbm -close_boundaries ${working_dir}/sampled_atlas.m ${working_dir}/sampled_atlas.m";
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = "$bin_dir/ccbbm -equalizearea ${working_dir}/mesh.m ${working_dir}/sampled_atlas.m ${working_dir}/sampled_atlas.m ${working_dir}/scale.txt";
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = "$bin_dir/ccbbm -transform_ucf  ${working_dir}/curve_tar_rot.ucf ${working_dir}/scale.txt ${working_dir}/curve_tar_scaled.ucf";
print "$Cmd_str\n";
system $Cmd_str;

##################################
###### end rescale atlas #########
##################################

	
$Cmd_str = single_line("perl $bin_dir/rigid_sphere_reg.pl $bin_dir $working_dir $bw ${working_dir}/sampled_atlas.m
			${working_dir}/mesh.m ${working_dir}/CC_sampled.m ${working_dir}/CC_sphere.m");
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = single_line("perl $bin_dir/demons_sphere_reg1.pl $bin_dir $working_dir $bw ${working_dir}/sampled_atlas.m
			${working_dir}/CC_sampled.m ${working_dir}/demons_warp1.m");
print "$Cmd_str\n";
system $Cmd_str;	


$Cmd_str = single_line("perl $bin_dir/sample_by_warp.pl $bin_dir $working_dir $bw ${working_dir}/mesh.m ${working_dir}/CC_sphere.m
			${working_dir}/sphere_ATL_rot.m ${working_dir}/demons_warp1.m ${working_dir}/Dem_resliced1.m");
print "$Cmd_str\n";
system $Cmd_str;


#########################################
#### on the fly ends projection #########
#########################################

$Cmd_str = single_line("$bin_dir/ccbbm -curve_function ${atlas_dir}/atlas_${label_id}.m ${atlas_dir}/curve_${label_id}.ucf 
			${working_dir}/GOF_atlas${label_id}.raw ${working_dir}/thick_atlas${label_id}.raw ${working_dir}/EndCoords_${label_id}.txt");
print "$Cmd_str\n";
system $Cmd_str;

#########################################
#### END on the fly ends projection #####
#########################################


$Cmd_str = single_line("$bin_dir/ccbbm -medial_curve_lim_res2 ${working_dir}/Dem_resliced1.m 0 15 300 $curve 
			-alpha2 3e-4 -init_fcn ${atlas_dir}/GOF_${label_id}.raw -proj_ends ${working_dir}/EndCoords_${label_id}.txt -max_bd_pts 0 ");
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = single_line("perl $bin_dir/demons_sphere_reg2.pl $bin_dir $working_dir $bw ${working_dir}/sampled_atlas.m ${working_dir}/CC_sampled.m
			${working_dir}/curve_tar_scaled.ucf $curve ${working_dir}/demons_warp1.m ${working_dir}/demons_warp2.m");
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = single_line("perl $bin_dir/sample_by_warp.pl $bin_dir $working_dir $bw ${working_dir}/mesh.m ${working_dir}/CC_sphere.m
			${working_dir}/sphere_ATL_rot.m ${working_dir}/demons_warp2.m $resliced");
print "$Cmd_str\n";
system $Cmd_str;


$Cmd_str = "$bin_dir/ccbbm -curve_function $resliced $curve ${working_dir}/res_GOF.raw $thick";
print "$Cmd_str\n";
system $Cmd_str;


################################
###### Shape TBM ###############
################################

$Cmd_str = single_line("perl $bin_dir/shape_TBM.pl $bin_dir $working_dir $resliced ${atlas_dir}/atlas_${label_id}.m $TBM");
print "$Cmd_str\n";
system $Cmd_str;

###############################
##############################
##############################


$Cmd_str = single_line("/usr/bin/perl $bin_dir/rename_with_int.pl $curve $output_dir curve $label_id");
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = single_line("/usr/bin/perl $bin_dir/rename_with_int.pl $resliced $output_dir resliced_mesh $label_id");
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = single_line("/usr/bin/perl $bin_dir/rename_with_int.pl $thick $output_dir thick $label_id");
print "$Cmd_str\n";
system $Cmd_str;

$Cmd_str = single_line("/usr/bin/perl $bin_dir/rename_with_int.pl $TBM $output_dir LogJacs $label_id");
print "$Cmd_str\n";
system $Cmd_str;



#$Cmd_str = "rm -r ${working_dir}";
#print "$Cmd_str\n";
#system $Cmd_str;




sub single_line {
 my @strings = @_;
 foreach ( @strings ) {
 s/\n/ /g;
 s/\r/ /g;
 }
 return wantarray? @strings : $strings[0];
}
