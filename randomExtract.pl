#!/usr/bin/perl -w
use strict;
use Data::Dumper;
my $usage=<<USAGE;
perl randomExtract.pl <IN1 total extracted lines nr. > <IN2 the file for extraction>
This is for extract lines form a file randomly.
USAGE
my $total_line_nr=`wc -l $ARGV[1]`;
die $usage if(@ARGV<2);
my $totaln=$ARGV[0];
my %hash;
while(1){
	if(scalar(keys %hash)==$totaln){
		last;
	}
	else{
		my $tmp=int(rand($total_line_nr));
		if(exists $hash{$tmp}){
			
		}
		else{
			$hash{$tmp}=0;
		}
	}
}print Dumper \%hash;
open(IN,"$ARGV[1]")||die "cannot open $ARGV[1]\n";
open(OUT,">$ARGV[1]\_random\_$totaln.txt")||die "Cannot output\n";
my $i=0;
while(<IN>){
	chomp;
	if(exists $hash{$i}){
		print OUT "$_\n";
	}
	$i++;
}
close IN;
close OUT;