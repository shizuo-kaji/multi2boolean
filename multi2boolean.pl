#! /usr/bin/perl
# @file multi2boolean.pl
# @brief A perl script to convert multilevel networks to Boolean networks
#        The algorithm is based on the paper
#        "A circuit-preserving mapping from multilevel to Boolean dynamics" by A. Faure and S. Kaji
#        and
#		 "On the conversion of multivalued gene regulatory networks to Boolean dynamics" by E. Tonello
# @par How to use: 
#      1. Define your model in the "Truth Table" (tt) format.
#         (GINSim can read and write tt files)
#      2. Feed the tt file to this script to obtain the converted Boolean model in the tt format.
# @par "Truth Table" (tt) format:
#      (for details, please refer to the GINSim manual http://ginsim.org/ginsim-doc/current/format-truthtable.html )
#      The first line contains a space/tab separated list of the names of the variables.
#      The second to last lines consist of two columns separated by space/tab;
#      each line contains a source state followed by its corresponding target state.
#      (thus, the maximum value for each gene is restricted to 9)
# @par Example of a tt file:
#      x1 x2 x3
#      000	120
#	   001	303
#      ...  ...
# @author Shizuo KAJI
# @date 20 Jan. 2017
# @copyright The MIT License

use strict;
use warnings;
use Getopt::Long 'GetOptions';

# print usage
if(@ARGV < 1) {
         print "Usage (Faure-Kaji): $0 input_file > output_file \n";
         print "Usage (Tonello): $0 -t input_file > output_file \n";
		 exit;
}

my $tonello = 0;
GetOptions('t'  => \$tonello);

# read the input file
my $inputfile = shift;
open(my $fh, "<", $inputfile) or die "Cannot open $inputfile: $!";
my @input = readline $fh; 
close $fh;

# variables and their max values
my @vars = split(/\s+/,shift(@input));
my @maxval = (0) x ($#vars+1);
foreach my $line (@input) {
	my ($s, $t) = split(/\s+/,$line);
	for (my $i = 0; $i <= $#vars; $i++){
		my $sv = substr($s,$i,1);
		$maxval[$i] = ($maxval[$i] > $sv) ? $maxval[$i] : $sv;
	}
}
for (my $i = 0; $i <= $#vars; $i++){
	if($maxval[$i]==1){
  		print "$vars[$i]"."\t";		
	}else{
		for (my $j = 1; $j <= $maxval[$i]; $j++){
			print "$vars[$i]".$j."\t";
		}
	}
}
print "\n";

# convert each line of truth table
foreach my $line (@input) {
	my ($s, $t) = split(/\s+/,$line);
#	print $s, "\t", $t, "\n";
	my @S = ("");
	my @T = ("");
	for (my $i = 0; $i <= $#vars; $i++){
		my $sv = substr($s,$i,1);
		my $tv = substr($t,$i,1);
		my @L = choose($maxval[$i],$sv);
		my (@newS, @newT);
		for (my $j = 0; $j <= $#S; $j++){
			# set source values 
			foreach my $l (@L){
				push @newS, $S[$j] . $l;
			}
			# set target values 
			if($sv<$tv){
				foreach my $l (@L){
					if($tonello){
						push @newT, $T[$j] . ("1" x ($sv+1)) . ("0" x ($maxval[$i]-$sv-1));
					}else{
						push @newT, $T[$j] . ("1" x $maxval[$i]);
					}
				}
			}elsif($sv == $tv){
				foreach my $l(@L){
					if($tonello){
						push @newT, $T[$j] . ("1" x $sv) . ("0" x ($maxval[$i]-$sv));
					}else{
						push @newT, $T[$j] . $l; 
					}
				}
			}elsif($sv > $tv){
				foreach my $l(@L){
					if($tonello){
						push @newT, $T[$j] . ("1" x ($sv-1)) . ("0" x ($maxval[$i]-$sv+1));
					}else{
						push @newT, $T[$j] . ("0" x $maxval[$i]); 
					}
				}
			}
		}
		@S = @newS;
		@T = @newT;
#		print join("\n", @T);
	}
	for (my $j = 0; $j <= $#S; $j++){
		print  $S[$j] . "\t" . $T[$j] . "\n";
	}	
}

# a function which returns an array of 01-strings of length $m containing $n 1's.
sub choose{
	my ($m, $n) = @_;
	if($n==0){
		return ("0" x $m);
	}elsif($n>$m){
		return ();
	}else{
		my @B0 = choose($m-1,$n);
		for (my $i = 0; $i <= $#B0; $i++){
			$B0[$i] = "0" . $B0[$i];
		}
		my @B1 = choose($m-1,$n-1);
		for (my $i = 0; $i <= $#B1; $i++){
			$B1[$i] = "1" . $B1[$i];
		}
		return (@B0,@B1);
	}
}
