#!/usr/bin/perl -w
use strict;
my $usage=<<USAGE;
perl extract_peak.pl <IN macs.xls>
USAGE
die $usage if(@ARGV<1);
open(IN,"$ARGV[0]")||die "could not open $ARGV[0], no such file or directory!\n";
open(OUT,">$ARGV[0]\_peak.txt")||die "could not output to $ARGV[0]\_peak.txt, no such file or directory!\n";
my($i,@line);
$i=0;
print OUT "\#chr\tabs_summit\n";
while(<IN>){
	chomp;
	$i++;
	@line=split/\t/,$_;
	if($i>27){
		print OUT "$line[0]\t$line[4]\n";
	}
}
close IN;
close OUT;