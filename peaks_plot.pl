#!/usr/bin/perl -w
use strict;
use GD;
use Data::Dumper;
require Math::Spline;

my $usage=<<USAGE;
perl plot.pl <IN  nearsetTss.txt list file>
This is a plot program for ploting the relation of the +/-50kb of each CHIPseq summit and the nearest distance to TSS of the features' peaks that are in the range of this region.
the input is a file listing the directory and file names of the features.
The input file should be of the following format:
directory/to/your/nearestTss/file\tfeature name(e.g. H3K4me1)\n
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
			push(@{$hash{$line[2]}{$line[1]}{$tmp[3]}},$tmp[4]);
		}
	}
	close FILE;
}#print Dumper \%hash;
#plot
my $resolution=0.9;#the dot that are in the range of the $resolution*$max_x and $resolution*$max_y
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
			for(@{$hash{$tmp}{$key}{$inner}}){
				if($_){
				push(@hold,abs($_));
				}
			}
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
#print "$hn\t$wn\n";
#horizonal lines and bars labels
#$hn=4;
#$wn=7;
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
my $dis=50000;#the flanking region is of 50kb, i.e. 50000bp
my $ban=200;#the binning region is fo 200bp
for my $sample(sort{$a cmp $b} keys %hash){
	$im->string(gdSmallFont, 0, $m+((($h-2*$m)/$hn)*($i+1))/2, $sample, $black);
	my $j=0;
	for my $feature(sort{$a cmp $b} keys $hash{$sample}){
		my $center_y=$m+((($h-2*$m)/($hn))*($i+1))-(($h-2*$m)/($hn*2));
		my $center_x=$m+(($w-2*$m)/$wn)*($j+1)-($w-2*$m)/($wn*2);
		$im->string(gdSmallFont, $center_x, $m*0.8, $feature, $black);
		$im->line($center_x,$h-$m,$center_x,$h-$m-0.01*($h-2*$m),$black);
		my %pos=(); my @y=(); my @x=();
##############

################
		for my $x(sort{$a<=>$b}keys $hash{$sample}{$feature}){
			#my $x1=$center+$x*((($w-2*$m)/($wn*2))/$dis);
			for(@{$hash{$sample}{$feature}{$x}}){
				if($_ && abs($_)<=$maxy[$j]){
					#collect all the dots that are in the range
					push(@{$pos{$_}},$x);
				}
			}
		}
		#print Dumper \%pos;
		for my $y1(sort{$b <=>$a}keys %pos){
			my $y2=$center_y+$y1*((($h-2*$m)/($hn*2))/($maxy[$j]));
			#my $win=$ban*((($w-2*$m)/($wn*2))/$dis);
			my $win=($w-2*$m)/@maxy;
			for(sort{$a<=>$b} @{$pos{$y1}}){
			#for(@{$pos{$y1}}){
				
				my $x1=$center_x+$_*((($w-2*$m)/($wn))/(2*$dis));
				#$im->line($x1-$win,$y2,$x1+$win,$y2,$purple);
				$im->filledEllipse($x1, $y2, 0.01*$win, 0.0001*$win,$purple);
			}
		}

################
=cut
		for my $x(sort{$a<=>$b}keys $hash{$sample}{$feature}){
			for(@{$hash{$sample}{$feature}{$x}}){
				if($_ && abs($_)<=$maxy[$j]){
					#collect all the dots that are in the range
					push(@{$pos{$_}},$x);
				}
			}
		}	
=cut
		$j++;
	}
	$i++;
}

 binmode OUT;
 print OUT $im->png;
 
close IN;
close OUT;