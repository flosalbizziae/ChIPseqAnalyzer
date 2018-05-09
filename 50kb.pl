#!/usr/bin/perl -w
use strict;
use Data::Dumper;
my $usage=<<USAGE;
perl search_50kb.pl <IN1 sample peaks.txt> <IN2 feature peak.txt>
This is for searching the peaks that are in the peak region.
IN1:	chr\tstart\tend\n
IN2:	chr\tstart\end\n
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
		my $left=$line[1]-$flanking;
		my $right=$line[2]+$flanking;
		my $str=$left."\t".$right;
		push(@{$hash{$line[0]}},$str);
	}
}
#print Dumper \%hash;
#assume that there is no overlap in summit regions
print OUT "\#chr\tstart\tend\tdistanceToSamplePeak\n";
while(<IN2>){
	chomp;
	@line=split/\t/,$_;
	if(exists $hash{$line[0]}){
		for(@{$hash{$line[0]}}){
			my @range=split/\t/,$_;
            if(($line[1]<=$range[0]&&$line[2]>=$range[1])||
            ($line[1]>$range[0]&&$line[1]<$range[1])||
            ($line[2]>$range[0]&&$line[1]<$range[1])){
            	my @hold=();
            	my %keep=();
            	push(@hold,abs($line[1]-$range[0]));
            	push(@hold,abs($line[1]-$range[1]));
            	push(@hold,abs($line[2]-$range[0]));
            	push(@hold,abs($line[2]-$range[1]));
            	#print Dumper \@hold;
            	$keep{abs($line[1]-$range[0])}.="\t".($line[1]-$range[0]);
            	$keep{abs($line[1]-$range[1])}.="\t".($line[1]-$range[1]);
            	$keep{abs($line[2]-$range[0])}.="\t".($line[2]-$range[0]);
            	$keep{abs($line[2]-$range[1])}.="\t".($line[2]-$range[1]);
            	my @sort_hold=sort{$a<=>$b} @hold;
            	my $key=$sort_hold[0];
            	my @dis=split/\t/,$keep{$key};
            	print Dumper \%keep;
            	#print Dumper \@dis;
            	if(@dis==1){
            		print OUT "$line[0]\t$line[1]\t$line[2]\t$dis[0]\n";
            	}
            	elsif(@dis>1){
            		print OUT "$line[0]\t$line[1]\t$line[2]\t$key\n"; 
            	}
            	else{
            	}
			}
		}
	}
}
close IN1;
close IN2;
