#!/usr/bin/perl -w
use strict;
open(IN,"$ARGV[0]")||die "Cannot open $ARGV[0]\n";
open(OUT,">$ARGV[0]\_shortest.txt")||die "cannot output\n";
while(<IN>){
	chomp;
	my @line=split/\t/,$_;
	if(!/^\#/){
		my @hold=();
		my %hash=();
		for(my $i=4;$i<@line;$i++){
			push(@hold,abs($line[$i]));
			push(@{$hash{abs($line[$i])}},$line[$i]);
		}
		use Data::Dumper;
		#print Dumper \@hold;
		my @sort=sort{$a<=>$b} @hold;
		print Dumper \@sort;
		my $dis=shift @sort;
		print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\t${$hash{$dis}}[0]\n";
	}
	else{
		print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\tDisToTSS\n";
	}
}
close IN;
close OUT;