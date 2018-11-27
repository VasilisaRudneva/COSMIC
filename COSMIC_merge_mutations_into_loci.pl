#! /usr/bin/env perl

use warnings;
use strict;

my $input_file = $ARGV[0];   
my $this_chr= $ARGV[1];
my $max_dist = $ARGV[2];

my @in = split("\\." , $input_file); 
my $base=shift(@in);
my $output_file=$base.".".$max_dist.".mutations_count.".$this_chr.".txt";

#print "Parameters: <$input_file> <$this_chr> <$max_dist>; Output: <$output_file>\n";

# Reading input file
open IN, "$input_file" or die "cannot open file: $input_file";
my @lines=<IN>; 
close IN;

my %output;

# COSM4970349	17	156220		1
# COSM4840555	17	156227		1
# COSM3755738	17	156237		1
my $first_line = shift(@lines);
chomp($first_line); $first_line =~ s/\r//g; $first_line =~ s/\r\n//g; $first_line =~ s/$//g;
my @all = split("\t" , $first_line); 
my $start = $all[2]; # 156220
my $end = $all[2];   # the same
my $count = 1;       # counts number of mutations within the region

while (@lines)
{
	my $this_line=shift(@lines); chomp($this_line); $this_line =~ s/\r//g; $this_line =~ s/\r\n//g; $this_line =~ s/$//g;

	my @all = split("\t" , $this_line); 
	my $position = $all[2]; # 156220

	my $mod=abs($position-$end);
	my $size=scalar @lines;

	if ($mod>$max_dist)
	{ 
	    my $res= $start."\t".$end;
	    my $len=$end-$start+1;
	    my $freq=sprintf("%.2f", $count/$len);
	    $output{$res}=$count."\t".$len."\t".$freq; 
	    $start=$position;
	    $end=$position;
	    $count=1;
	} 
	else 
	{
	    $end=$position;
	    $count++;
	}
	if (scalar @lines == 0) { 
	    my $res= $start."\t".$end;
	    my $len=$end-$start+1;
	    my $freq=sprintf("%.2f", $count/$len);
	    $output{$res}=$count."\t".$len."\t".$freq; 
}
}

open OUT, ">$output_file" or die $!;
foreach my $this_record (sort keys %output)
{
	print OUT "$this_chr\t$this_record\t$output{$this_record}\n";
}	
close OUT;

