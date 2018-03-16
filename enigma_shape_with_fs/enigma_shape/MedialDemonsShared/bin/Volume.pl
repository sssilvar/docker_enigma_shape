use Math::Complex;
use File::Basename;
use Cwd;

if($#ARGV < 2)
{
	die(single_line("usage: perl Volume.pl [input directory] [output directory] [label id 1] .... [label id N] "));
}



$N = $#ARGV - 1;
printf "N = $N\n";

$input_dir = $ARGV[0];
$output_dir = $ARGV[1];
$bin_dir = "/ifshome/bgutman/MedialDemons4grid/bin";


printf("$output_dir\n");
printf("$output_dir\n");

$CmdStr = "mkdir -p $output_dir\n";
print $CmdStr;
system $CmdStr;

$filestr = " ";

foreach $i (2 .. ($N+1)) 
{   
    $CmdStr = "${bin_dir}/ccbbm -store_volume ${input_dir}/resliced_mesh_${ARGV[$i]}.m ${output_dir}/vol_${ARGV[$i]}.txt\n";
    print $CmdStr;
    system $CmdStr; 
    
    $filestr = $filestr . sprintf("${output_dir}/vol_${ARGV[$i]}.txt ");
}

$CmdStr = "${bin_dir}/concatenate ${output_dir}/vols_all.txt $filestr \n";
print $CmdStr;
system $CmdStr;

$CmdStr = "${bin_dir}/text2raw ${output_dir}/vols_all.txt ${output_dir}/volumes_0.raw\n";
print $CmdStr;
system $CmdStr;

$CmdStr = "rm -R  $filestr\n";
print $CmdStr;
system $CmdStr;
	
sub single_line {
 my @strings = @_;
 foreach ( @strings ) {
 s/\n/ /g;
 s/\r/ /g;
 }
 return wantarray? @strings : $strings[0];
}