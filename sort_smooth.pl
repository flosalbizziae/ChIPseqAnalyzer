#!/usr/bin/perl -w
use strict;
use Data::Dumper;
my $usage=<<USAGE;
perl sort.pl <IN overlap out file>
This script is using for sorting peaks and prepare data usable for plot_final.r
USAGE
die $usage if(@ARGV<1);
open(IN,"$ARGV[0]")||die "cannot open $ARGV[0]\n";
open(OUT,">$ARGV[0]\_sort.txt")||die "cannot output\n";
my(@line,%hash,%sort,%hold,$key,$tmp,$k);
while(<IN>){
	chomp;
    @line=split/\t/,$_;
	$hash{"$line[0]\t$line[1]\t$line[2]"}{$line[3]}+=1;
}
#print Dumper \%hash;

for $key(keys %hash){
	my @keep=();
	for $k(keys $hash{$key}){
		push(@keep,$k);

	}
	#print Dumper \@keep;
	my @sort=sort @keep;
	my $most=pop @sort;
	#print "$most\n";
	$hold{$most}.=",$key";
}
#print Dumper \%hold;

my %list_lowess=();
my @list=();
open(TMP,">lowess.tmp")||die "cannot create temp file\n";
for $key(sort{$b<=>$a} keys %hold){
	$hold{$key}=~s/,//;
	my @peak=split/\,/,$hold{$key};
	for(@peak){
		push(@list, $_);
        print TMP "$_\t$key\n";
	}
}
=cut
#print Dumper \@list;
#close TMP;
$k=0;
for(@list){
    my $peak=$_;
    $k++;
    for $key(sort{$b<=>$a} keys $hash{$peak}){
        print OUT "$k\t$key\n";
    }
}

close IN;
close OUT;
=cut

my $rscript=<<R;
data<-read.table("lowess.tmp",header=F,sep="\t")
smooth<-lowess(seq(1,length(data[,1])),data[,4])
write.table(cbind(data,smooth\$y),"smooth.tmp",sep="\t",quote=F,row.names = F,col.names = F)
R

open(RS,">lowess.r")||die "cannot create lowess.r\n";
print RS "$rscript";
close RS;

system("R <lowess.r --vanilla");


open(SM,"smooth.tmp")||die "cannot open smooth.txt";
while(<SM>){
    @line=split/\t/,$_;
    $list_lowess{"$line[0]\t$line[1]\t$line[2]"}{$line[3]}=$line[4];
}
close SM;

$k=0;
for(@list){
	my $peak=$_;
	$k++;
	for $key(sort{$b<=>$a} keys $hash{$peak}){
        if(exists $list_lowess{$peak}{$key}){
            print OUT "$k\t$list_lowess{$peak}{$key}"
        }
        else{
            print OUT "$k\t$key\n";
        }
	}
}

close IN;
close OUT;

my $check_org=`wc -l $ARGV[0]`;
my $check_tst=`wc -l $ARGV[0]\_sort.txt`;
my $test_org=(split/\s/,$check_org)[-2];
my $test_tst=(split/\s/,$check_org)[-2];

if($test_org==$test_tst){
    `rm lowess.tmp lowess.r smooth.tmp`;
}

