#!/usr/bin/perl -w
use strict;
open(IN1,"hg19_refseqGene_tss.txt")||die "cannot open reference\n";
open(IN2,"data/T47D-CHD4KD-TRPS1_peaks.xls_anno.txt")||die "cannot open the genes file\n";
open(OUT,">hg19_refseq_nearestTss.txt")||die "cannot output\n";
my(@line,%hash,$tmp,$key,%hold);
while(<IN1>){
	chomp;
	@line=split/\t/,$_;
	if(!/^\#/){
		push(@{$hold{$line[5]}},$line[3]);
		push(@{$hold{$line[5]}},$line[4]);
		$hash{$line[5]}="$line[1]\t$line[2]";
	}
}
close IN1;
print OUT "\#GeneSymbol\tChr\tStrand\tStart\tEnd\n";
while(<IN2>){
	chomp;
	@line=split/\;/,$_;
	for(@line){
		if(exists $hold{$_} && exists $hash{$_}){
			my @sort=sort @{$hold{$_}};
			my $start=shift @sort;
			my $end=pop @sort;
			print OUT "$_\t$hash{$_}\t$start\t$end\n";
		}
		else{
			#die "The gene symbols $_ are not of the same\n";
			print "$_\n";
		}
	}
}
close IN2;
close OUT;
		