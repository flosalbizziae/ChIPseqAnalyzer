#!/usr/bin/perl -w
use strict;
my $usage=<<USAGE;
perl nearest_tss.pl <IN1 hg19_refseq_nearestTss.bed> <IN2 *_region.txt>
This is for earching the nearest TSS and calculate the distance to it.
USAGE
die $usage if(@ARGV<2);

open(IN1,"$ARGV[0]")||die "could not open $ARGV[0]\n";
my(@line,$tmp,%hash,@id);
while(<IN1>){
	chomp;
	@line=split/\t/,$_;
	if(!/^\#/){
		if($line[2] eq "+"){
			push(@{$hash{$line[1]}},$line[3]);
		}
		else{
			push(@{$hash{$line[1]}},$line[4]);
		}
		push(@id,$line[0]);
	}
}
close IN1;


open(IN2,"$ARGV[1]")||die "could not open $ARGV[1]\n";
open(OUT,">$ARGV[1]\_$ARGV[0]")||die "could not output to $ARGV[1]\_$ARGV[0]\n";
while(<IN2>){
	chomp;
	@line=split/\t/,$_;
	my $distance=0;
	if(!/^\#/){
		if(exists $hash{$line[0]}){
			print OUT "$_";
			for(@{$hash{$line[0]}}){
				my $dist=$line[1]+(($line[2]-$line[1])/2)-$_;
				print OUT "\t$dist";
			}
			print OUT "\n";
		}
		else{
			#die "Please make sure you are using the concordent refernece\n";
			print "$_\n";
		}
	}
	else{
		print OUT "$_\t".join("\t",@id)."\n";
	}
}
close IN2;
close OUT;
					
			
