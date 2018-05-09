#!/usr/bin/perl -w
use strict;
open(IN1,"evt.txt")||die "cannot open evt.txt\n";
open(IN2,"merge_normalized.txt_genes.txt_selectedGenes.txt_samplename.txt")||die "cannot open the input\n";
open(OUT,">merge_normalized.txt_genes.txt_selectedGenes.txt_samplename.txt_evt.txt")||die "cannot output\n";
my(@line,%hash,$key,$tmp);
while(<IN1>){
	chomp;
	@line=split/\t/,$_;
	$line[0]=uc $line[0];
	$hash{$line[0]}="$line[1]\t$line[2]";
}
close IN1;
while(<IN2>){
	chomp;
	@line=split/\t/,$_;
	if(!/^Accession/){
		$line[0]=uc $line[0];
		if(exists $hash{$line[0]}){
			print OUT "$_\t$hash{$line[0]}\n";
		}
	}
	else{
		print OUT "$_\tSurvivalTime\tFinalResult\n";
	}
}
close IN2;
close OUT;