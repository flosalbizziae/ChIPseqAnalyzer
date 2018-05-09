#!/usr/bin/perl -w
use strict;
my $usage=<<USAGE;
perl nearest_tss.pl <IN1 hg19_tss_uniq.bed> <IN2 *_region.txt>
This is for earching the nearest TSS and calculate the distance to it.
USAGE
die $usage if(@ARGV<2);
open(IN1,"$ARGV[0]")||die "could not open $ARGV[0]\n";
my(@line,$tmp,%hash);
while(<IN1>){
	chomp;
	@line=split/\t/,$_;
	if($line[1] eq "+"){
		push(@{$hash{$line[0]}},$line[2]);
	}
	else{
		push(@{$hash{$line[0]}},$line[3]);
	}
}
close IN1;
open(IN2,"$ARGV[1]")||die "could not open $ARGV[1]\n";
open(OUT,">$ARGV[1]\_nearestTss.txt")||die "could not output to $ARGV[1]\_nearestTss.txt\n";
while(<IN2>){
	chomp;
	@line=split/\t/,$_;
	my $distance=0;
	if(!/^\#/){
		if(exists $hash{$line[0]}){
			my @sort=sort{$a<=>$b} @{$hash{$line[0]}};
			my $list=&bisection($line[3],@sort);
			my($start,$end)=split/\t/,$list;
			my $result=$start<=>$end;
			if($result==0){
				print OUT "$_\t0\n";
			}
			else{
				my $com=(abs($line[3]-$sort[$start]))<=>(abs($line[3]-$sort[$end]));
				if($com<=0){
					#$distance=abs($line[3]-$sort[$start]);
					$distance=$line[3]-$sort[$start];
				}
				else{
					#$distance=abs($line[3]-$sort[$end]);
					$distance=$line[3]-$sort[$end];
				}
				print OUT "$_\t$distance\n";
			}
		}
	}
	else{
		print OUT "$_\tDistanceToNearestTSS\n";
	}
}
close IN2;
close OUT;
					
			
#---------------------subroutine-----------------------------#			
sub bisection{
	my $value=shift @_;
	#my @tmp=@_;
	#my @list=sort{$a<=>$b} @tmp;
	my @list=@_;
	my $mid=@list-1;
	my $n=0;
	my $lastn=$n;
	my $lastmid=$mid;
	if($value<=$list[0]){
		return "0\t0";
	}
	elsif($value>=$list[-1]){
		return "$mid\t$mid";
	}
	else{
		while($mid-$n>1){
			
			#print "$n\t$mid\t$lastn\t$lastmid\t";
			
			$mid=int(($mid-$n)/2)+$n;
			
			#print "$mid\n";
			my $direction=$value <=> $list[$mid];
			if($direction==0){
				$n=$mid;
				last;
			}
			elsif($direction<0){
			
				$mid=$mid;
				$n=$lastn;
			}
			else{
				$n=$mid;
				$mid=$lastmid;
			}
			$lastmid=$mid;
			$lastn=$n;
		}
	
	}
	return "$n\t$mid";
}