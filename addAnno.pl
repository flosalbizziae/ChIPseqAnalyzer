#!/usr/bin/perl -w
use strict;
my $usage=<<USAGE;
perl addAnno.pl <IN1 out from affy analysis.txt> <IN2 out from annotation of probes>
USAGE
die $usage if(@ARGV<2);
open(IN1,"$ARGV[0]")||die "cannot open $ARGV[0]\n";
open(IN2,"$ARGV[1]")||die "cannot open $ARGV[1]\n";
open(OUT,">$ARGV[0]\_$ARGV[1]")||die "cannot output\n";
my(@line,%hash,$tmp);
my $i=0;
while(<IN2>){
	chomp;
	@line=split/\t/,$_;
	if($i>0){
		$hash{$line[1]}="$line[2]\t$line[3]";
	}
	$i++;
}
$i=0;
while(<IN1>){
	chomp;
	@line=split/\t/,$_;
	if($i>0){
		if(exists $hash{$line[0]}){
			print OUT "$_\t$hash{$line[0]}\n";
		}
		else{
			print OUT "$_\tNA\tNA\n";
		}
	}
	else{
		print OUT "ProbeID".$_."\tSYMBOL\tGENENAME\n";
	}
	$i++;
}

close IN1;
close IN2;
close OUT;			