#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;

my $DEBUG = 0;

my ($secret_count, $secret_name);
my %list_items;
my $cnt_items = 0;
my @sctl_list = `sudo sctl list`;
print "Processing the following secrets ...\n";
foreach my $item (@sctl_list) {
    chomp($item);
    print $item . "\n";
    if ($item =~ /^[0-9]/) {
        $cnt_items++;
        my ($secret_count, $secret_name) = $item =~ /^([0-9]+)] (.*)$/;
        $secret_count = sprintf("%03d", $secret_count);
    #    print "$secret_count - $secret_name\n";
		$list_items{"$secret_count"} = $secret_name;
    }
}

print "TOTAL ITEM COUNT: $cnt_items\n\n";

foreach my $secret_count (sort keys %list_items) {
    my $secret_name = $list_items{$secret_count};
    $secret_count =~s /^0{1,2}//g; 
    my $secret = `sudo sctl read $secret_count`;
    chomp($secret);
    #$secret =~s /A new version of sctl is available: current=1.5.0, latest=1.6//;
    $secret =~s /.*A new version of sctl is available: current=1.5.0, latest=1.6.*//;
    print "#######################################################################\n";
    print "$secret_count - $secret_name\n";
    print "#######################################################################\n";
    print "$secret\n\n";
}

exit(0);
