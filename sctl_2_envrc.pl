#!/usr/bin/env perl

use strict;
use warnings;
use Cwd 'chdir';

my $DEBUG = 1;

#my $sign_in = `eval \$(op signin --raw)`;
print "Please login to 1pass.\n";
my $session_token = `op signin --raw`;
if ($DEBUG) {
	print "session_token = $session_token\n";
}

my @paths = (
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/virtual-usa/development/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/virtual-usa/preview/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/metrics/canary/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/metrics/network/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/metrics/build/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/netbox/network-v2/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/netbox/production/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/vapor-cloud-platform/environments/canary/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/vapor-cloud-platform/environments/nightly/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/vapor-cloud-platform/environments/productionv2/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/vapor-cloud-platform/environments/preview/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/jenkins-job-triggers/environments/build/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/edge-events/local/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/development/uuidaas/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/development/vna-emulator/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/development/consumer-api/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/development/vator/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/development/management-api/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/development/map-feature-api/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/development/kinetic-grid-portal/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/development/map-feature-ui/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/development/network-api/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/ci-cd-scanners/environments/build/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/ingress-controllers/production-v2/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/ingress-controllers/canary/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/ingress-controllers/development/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/ingress-controllers/network/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/ingress-controllers/atlantis/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/ingress-controllers/sandbox/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/ingress-controllers/production/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/ingress-controllers/build/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/atlantis/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/kinetic-grid-demo/development-v2/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/vapor-cloud-platform-dcim/environments/development/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/vapor-cloud-platform-dcim/environments/productionv2/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/vapor-cloud-platform-dcim/environments/preview/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/syslog-ng/network/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/prometheus-snmp/network/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/logging/environments/canary/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/logging/environments/development/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/observability-pipeline/environments/development/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/observability-pipeline/environments/production/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/analytics/environments/development/",
    "/Users/sdicki/Development/git/vapor-io/cloud-ops/analytics/environments/production/",
);

my $cnt_items_gtotal = 0;
foreach my $path (@paths) {
	$path =~s /\/$//;
	chdir "$path";
    print "$path\n";
    my $secret_key = $path;
    $secret_key =~s /environments\///;
    $secret_key =~s /\/Users\/sdicki\/Development\/git\/vapor-io\/cloud-ops\///;
    $secret_key =~s /\/Users\/sdicki\/Development\/git\/vapor-io\/edge-ops\///;
    $secret_key =~s /\//-/g;
    my ($secret_count, $secret_name);
    my %list_items;
    my $cnt_items = 0;
    my @sctl_list = `sudo sctl list`;
    print "#######################################################################\n";
    print "Processing the following secrets for:\n";
    print "$path\n";
    print "#######################################################################\n";
    foreach my $item (@sctl_list) {
        chomp($item);
        $cnt_items_gtotal++;
        if ($item =~ /A new version of sctl is available:/) {next;}
        print $item . "\n";
        if ($item =~ /^[0-9]/) {
            $cnt_items++;
            my ($secret_count, $secret_name) = $item =~ /^([0-9]+)] (.*)$/;
            $secret_count = sprintf("%03d", $secret_count);
    		$list_items{"$secret_count"} = $secret_name;
        }
    }
    
    if (! -d "/Users/sdicki/Library/Caches/tmp") {
        mkdir("/Users/sdicki/Library/Caches/tmp", 0755);
	}	 	
	my $tmp_file = "/Users/sdicki/Library/Caches/tmp/scuttle_verify_${secret_key}.tmp";
    if (-e $tmp_file) {
        print "Temp file exists: $tmp_file\n";
        print "Already done .. skipping ..\n\n";
		next;
	} else {
		open TMP, ">>$tmp_file" or die "touch $tmp_file: $!\n";
		close TMP;
	}

    print "TOTAL ITEM COUNT: $cnt_items\n\n";
    
    my $envrc_file = "$path/.envrc";
    if (-e "$envrc_file") {
        print "Envrc file exists: $envrc_file\n";
        print "Already done .. skipping ..\n\n";
		next;
	}

    foreach my $secret_count (sort keys %list_items) {
        my $secret_name = $list_items{$secret_count};
        $secret_count =~s /^0{1,2}//g; 
        my $secret = `sudo sctl read $secret_count`;
        chomp($secret);
        #$secret =~s /A new version of sctl is available: current=1.5.0, latest=1.6//;
        $secret =~s /.*A new version of sctl is available: current=1.5.0, latest=1.6.*//;
        $secret =~s /\n$//g;
        print "#----------------------------------------------------------------------\n";
        print "$secret_count - $secret_name\n";
        print "#----------------------------------------------------------------------\n";
        print "$secret";
        my $op_path = "op://secrets-automation-sea/${secret_key}/${secret_name}";
        my $op_cmd = "op read ${op_path}";
        my $op_cmd_with_session = "op --session ${session_token} read ${op_path}";
        my $export_cmd = "export ${secret_name}=\"\$(${op_cmd})\"";
        my $current_value = `${op_cmd_with_session}`;
        chomp($current_value);
        $current_value =~s /\n$//g;
        if ($DEBUG) {
            print "\nDEBUG MODE:\n";
            print "op_cmd_with_session: $op_cmd_with_session\n";
    	    print "secret_key = $secret_key\n";
    	    print "secret_name = $secret_name\n";
    	    print "current_value = $current_value\n";
			print "EXPORT: $export_cmd\n";
			print"\n";
        }
    	if ($secret eq $current_value) {
    		print " [OK]";
    	} else {
            unlink("$envrc_file");
            unlink("$tmp_file");
    		print " [ERROR: NON-MATCHING SECRET]";
        	print "\n\n";
			exit(1);
    	}
        print "\n\n";
        open (ENVRC, ">>$envrc_file") or die "Could not open $envrc_file!";
        print ENVRC "$export_cmd\n";
        close (ENVRC);
    }
}

print "\n\nTOTAL PASSWORDS MIGRATED: ${cnt_items_gtotal}\n\n";

exit(0);
