#!/usr/bin/perl -w

use strict;
use GD;
use Data::Dumper;

my $usage=<<USAGE;
[SYNOPSIS]

	perl plot.pl <IN feature_list_file.txt>

[DESCRIPTION]

	This is a plot program for ploting the relation of the +/-50kb of each CHIPseq summit and the enriched realated features' peaks that are in the range of the region of either the CHIPseq peaks or other types of regions.Tthe input is a file listing the directory and file names of the features, and the input file should be a tab-deliminated text file containing the following three columns:
	1. directory/to/your/file
	2. feature_name(e.g. H3K4me1)
	3. sample(the ChIPseq experiments)
	
	And most impoartantly, the file of the first column in the feature list file should a tab-delminated text file containing the two columns of:
	1. Index_of_the_peaks
	2. distance_to_the_summit.
	
	All the files' header should start with a #.

USAGE

die $usage if(@ARGV<1);

open(IN,"$ARGV[0]")||die "could not open $ARGV[0]\n";
open(OUT,">$ARGV[0].png")||die "could not output to $ARGV[0].png\n";
my(@line,%hash,$tmp,@tmp);
while(<IN>){
	chomp;
	@line=split/\t/,$_;
	open(FILE,"$line[0]")||die "could not open $line[0]\n";
	while(<FILE>){
		chomp;
		@tmp=split/\t/,$_;
		if(!/^\#/){
			$hash{$line[2]}{$line[1]}{$tmp[0]}=$tmp[1];
		}
	}
	close FILE;
}#print Dumper \%hash;
#plot

my $resolution=0.8;#the dot that are in the range of the $resolution*$max_x and $resolution*$max_y
my $w=1000;#width of the graph
my $h=700;#height of the graph
my $m=$h/8;#margin of the graph
my $im = new GD::Image($w,$h);
my $white = $im->colorAllocate(255,255,255);
my $black = $im->colorAllocate(0,0,0);       
my $red = $im->colorAllocate(255,0,0);      
my $blue = $im->colorAllocate(0,0,255);
my $green=$im->colorAllocate(0,139,0);
my $purple=$im->colorAllocate(125,38,205);
my $lightblue=$im->colorAllocate(72,118,255);
my $pink=$im->colorAllocate(255,187,255);

#$im->transparent($white);
#$im->interlaced('true');
#plot area
$im->rectangle($m,$m,$w-$m,$h-$m,$black);

#parameters settings
my $hn=scalar(keys %hash);
my %adjust;
my $flg=0;
my $i=0;
my @maxy;
#print Dumper \%hash;
for $tmp(sort{$a cmp $b}keys %hash){
	$flg+=scalar(keys $hash{$tmp});
	for my $key(sort{$a cmp $b}keys %{$hash{$tmp}}){
		$adjust{$key}=0;
		my $nn=0;
		my $max=0;
		my @hold=();
		for my $inner(keys $hash{$tmp}{$key}){
			push(@hold,abs($hash{$tmp}{$key}{$inner}));
		}
		my @holdsort=sort{$a<=>$b} @hold;
		my $thrs=0;
		for(@holdsort){
			$thrs++;
		}
		my $per;
		if($resolution==1){
			$per=$thrs-1;
		}
		elsif($resolution<1){
			$per=int($resolution*$thrs);
		}
		else{
			die "Error! The resolution should be float no larger than 1!\n";
		}
		$max=$holdsort[$per];
		push(@maxy,$max);
	}
	$i++;
}
#print Dumper \@maxy;
my $wn=scalar(keys %adjust);
if(($flg/$i)!=$wn){
	die "There might be features left for some of the samples, please check your feature list!\n";
}

#horizonal lines and bars labels
my @color=($red,$green,$blue,$pink);
if($hn>1){
	for(1..$hn){
		$im->line($m, $m+(($h-2*$m)/$hn)*$_, $w-$m, $m+(($h-2*$m)/$hn)*$_, $black);
		$im->filledRectangle($m-($m/6),$m+(($h-2*$m)/$hn)*($_-1), $m-$m/12, $m+(($h-2*$m)/$hn)*$_, $color[$_-1]);
	}
}
#vertical lines
if($wn>1){
	for(1..$wn-1){
		$im->dashedLine($m+(($w-2*$m)/$wn)*$_, $m, $m+(($w-2*$m)/$wn)*$_, $h-$m,$lightblue);
	}
}
#
$i=0;
my $dis=50000;#the flanking region is of 50kb
my $ban=200;
for my $sample(sort{$a cmp $b} keys %hash){
	$im->string(gdSmallFont, 0, $m+((($h-2*$m)/$hn)*($i+1))/2, $sample, $black);
	my $j=0;
	my($feature,$index);
	for $feature(sort{$a cmp $b} keys $hash{$sample}){
		my $center_x=$m+(($w-2*$m)/$wn)*($j+1)-($w-2*$m)/($wn*2);
		$im->string(gdSmallFont, $center_x, $m*0.8, $feature, $black);
		$im->line($center_x,$h-$m,$center_x,$h-$m-0.01*($h-2*$m),$black);
		my $nr_of_peak=scalar(keys $hash{$sample}{$feature});
		for $index(sort{$a<=>$b} keys $hash{$sample}{$feature}){
			if($hash{$sample}{$feature}{$index}<=$maxy[$j]){
				my $y=$m+(($h-2*$m)/$nr_of_peak)*$index;
				my $x=$center_x+$hash{$sample}{$feature}{$index}*((($w-2*$m)/$wn)/(2*$dis));
				$im->filledEllipse($x,$y,0.1,0.2,$purple);
			}
		}
		$j++;
	}
	$i++;
}

 binmode OUT;
 print OUT $im->png;
 
close IN;
close OUT;