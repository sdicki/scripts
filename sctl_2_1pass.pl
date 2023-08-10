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

#open (, "<$template_file") or die "Could not open $template_file!";
#open (TMP_FILE, ">$tmp_file") or die "Could not open $tmp_file!";
#while (<TEMPLATE>) {
#    chomp($_);
# 	$_ =~s /<TEMPLATE_RULE_GROUP>/${rule_group}/;
#    $_ =~s /<TEMPLATE_RULE_GROUP_NAME>/${rule_group_name}/;
#    $_ =~s /<TEMPLATE_RULE_NAME>/${rule_name}/;
#    $_ =~s /<TEMPLATE_INSTANCE>/${rule_instance}/;
#	if ($_ =~ /<TEMPLATE_DASHBOARD_UID>/) {
#		if ($dashboard_uid) {
#			$_ =~s /<TEMPLATE_DASHBOARD_UID>/${dashboard_uid}/;
#		} else {
#			next;
#		}
#	}
#	if ($_ =~ /<TEMPLATE_PANEL_ID>/) {
#		if ($panel_id) {
#			$_ =~s /<TEMPLATE_PANEL_ID>/${panel_id}/;
#		} else {
#			next;
#		}
#	}
#
#    print TMP_FILE $_ . "\n";
#}
#close (TMP_FILE);
#close (TEMPLATE);
#
#move($tmp_file, $new_file) or die "Move failed: $!";
#
#if ($verbose) {
#	my @diff = `diff $template_file $new_file`;
#    print "====================================================================\n";
#	print "verbose mode [on]\n";
#    print "====================================================================\n";
#    print "Changes made: > diff $template_file $new_file:\n\n";
#    foreach my $i (@diff) {
#        chomp($i);
#		print "$i\n";
#	}
#    print "\n";
#    print "====================================================================\n";
#}
#
#print "\nNew alert file created:\n";
#print "$new_file\n\n";
#
#if ($verbose) {
#    print "NOTE: You will need to make sure that '__dashboardUid__' and '__panelId__' are set correctly in this new alert file, otherwise alerts won't be associated properly to those entities.\n";
#    print "      The '__dashboardUid__' can be found in the respective dashboard's url (i.e. 'https://graphs.vio.sh/d/xtkCtBkiz_2/website-health-preview?orgId=1&refresh=1h')\n";
#    print "                                                                                                           ^^^^^^^^^^^\n";
#    print "      The '__panelId__' can be found in the respective dashboard's top most panel, in the json model (i.e. ' \"id\": 138,')\n";
#    print "                                                                                                                   ^^^\n\n";
#}

exit(0);
