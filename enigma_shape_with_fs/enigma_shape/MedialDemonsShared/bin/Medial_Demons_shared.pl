use Math::Complex;
use File::Basename;
use Cwd;

if($#ARGV < 5)
{
	die(single_line("usage: perl Medial_Demons_multiROI.pl [FreeSurfer aseg file] 
	[label id 1] .... [label id N] [output directory] [medial directory] [FreeSurfer program directory]"));
}



$N = $#ARGV - 3;
printf "N = $N\n";

#$DemonsScript = $ARGV[0];

$aseg_file = $ARGV[0];
$output_dir = $ARGV[$N + 1];
$medial_dir = $ARGV[$N + 2];
$FS_dir = $ARGV[$N + 3];

#printf("$DemonsScript\n");
printf("$aseg_file\n");
printf("$output_dir\n");
printf("$medial_dir\n");
printf("$FS_dir\n");


foreach $i (1 .. ($N)) 
{
   
    $CmdStr = "perl ${medial_dir}/bin/Medial_Demons3.pl $aseg_file $ARGV[$i] $output_dir $medial_dir $FS_dir\n";
    print $CmdStr;
    system $CmdStr; 
}

	
sub single_line {
 my @strings = @_;
 foreach ( @strings ) {
 s/\n/ /g;
 s/\r/ /g;
 }
 return wantarray? @strings : $strings[0];
}