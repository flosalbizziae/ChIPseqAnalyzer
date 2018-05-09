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
	if(!/^\#/){
		if($line[2] eq "+"){
			push(@{$hash{$line[1]}},$line[3]);
		}
		else{
			push(@{$hash{$line[1]}},$line[4]);
		}
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
			my $list_1=&bisection($line[1],@sort);
			my $list_2=&bisection($line[2],@sort);
			
			my($start_1, $end_1)=split/\t/,$list_1;
			my($start_2, $end_2)=split/\t/,$list_2;
			
			my $result_1=&decide($line[1],$start_1, $end_1, @sort);
			my $result_2=&decide($line[2],$start_2, $end_2, @sort);#print "$result_1\t$result_2\n";
			
			my $adj=abs($result_1)<=>abs($result_2);#print "$adj\n";
			if($adj<0){
				print OUT "$_\t$result_1\n";
			}
			elsif($adj>0){
				print OUT "$_\t$result_2\n";
			}
			else{#print "$_\t$start_1\t$end_1\t$start_2\t$end_2\n";
				die "Errors! The peaks two sides has equal distance to TSS, which is unreasonable!\n";
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

sub decide{
			my $origin=shift;
			my $start=shift;
			my $end=shift;
			my @sort=@_;
			my $distance;
			
			my $result=$start<=>$end;
			
			if($result==0){
				$distance=0;
			}
			else{
				my $com=(abs($origin-$sort[$start]))<=>(abs($origin-$sort[$end]));
				if($com<=0){
					#$distance=abs($line[3]-$sort[$start]);
					$distance=$origin-$sort[$start];
				}
				else{
					#$distance=abs($line[3]-$sort[$end]);
					$distance=$origin-$sort[$end];
				}
				return $distance;
			}
}