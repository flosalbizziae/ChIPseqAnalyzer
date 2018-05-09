#!/usr/bin/perl -w
use strict;
use Data::Dumper;
my $usage=<<USAGE;
perl search_50kb.pl <IN1 summit.txt> <IN2 feature peak.txt>
This is for searching the peaks that are in the summit region.
USAGE
die $usage if(@ARGV<2);
my $flanking=50000;
my(@line,%hash,$key,$center);
open(IN1,"$ARGV[0]")||die "could not open $ARGV[0]!\n";
open(IN2,"$ARGV[1]")||die "could not open $ARGV[1]!\n";
my $infile=(split/\//,$ARGV[0])[-1];
open(OUT,">$ARGV[1]\_$infile\_region.txt")||die "could not output to $ARGV[1]\_$infile\_region.txt!\n";

while(<IN1>){
	chomp;
	@line=split/\t/,$_;
	if(!/^\#/){
		push(@{$hash{$line[0]}},$line[1]);
	}
}

#assume that there is no overlap in summit regions
print OUT "\#chr\tstart\tend\tcenter\tdistanceToSummit\n";
while(<IN2>){
	chomp;
	@line=split/\t/,$_;
	if(exists $hash{$line[0]}){
		for(@{$hash{$line[0]}}){
            #if(($line[1]<$_-$flanking&&$line[2]>=$_-$flanking)||($line[1]>=$_-$flanking&&$line[2]<=$_+$flanking)||($line[1]<$_+$flanking&&$line[1]>=$_+$flanking)){
            if(($line[1]<=$_-$flanking&&$line[2]>=$_+$flanking)||
            ($line[1]>=$_-$flanking&&$line[2]<=$_+$flanking)||
            ($line[1]<=$_+$flanking&&$line[2]>=$_+$flanking)||
            ($line[1]<=$_-$flanking&&$line[2]>=$_-$flanking)){
				if(($line[2]-$line[1])%2==0){
					$center=$line[1]+(($line[1]-$line[1])/2);
				}
				else{
					$center=$line[1]+(($line[2]-$line[1]-1)/2);
				}
				$key=$_-$center+1;
				print OUT "$line[0]\t$line[1]\t$line[2]\t$center\t$key\n";
			}
		}
	}
}
close IN1;
close IN2;
