#!/usr/bin/env perl

use strict;
use warnings;
use URI::Split qw(uri_split uri_join);
use File::Copy;
use Getopt::Long;

my $DEBUG = 0;

my $site_code = "";
my $site_suburb = "";
my $site_city = "";
my $site_state = "";
my $datasource_uid = "";
my $panel_id_airflow = "X";
my $panel_id_humidity = "X";
my $panel_id_power = "X";
my $panel_id_pressure = "X";
my $panel_id_temperature = "X";
my $panel_id_incoming = "X";
my $humidity_check = 0;
my $humidity_style_prompt = "";
my $humidity_style = "new";
my $hardware_model = "";
my $help;
my $verbose;

GetOptions ("debug"             => \$DEBUG,
            "help"              => \$help,
            "verbose"           => \$verbose)
or die("Error in command line arguments\n");

usage() if $help;

sub usage {
    my $cmd = $0;
    print "\n";
    printf("Usage: %s --debug --help --verbose\n", $cmd);
    print "\n";
    print "   --debug                  Turn on debug mode.\n";
    print "   --help                   This usage message.\n";
    print "   --verbose                Turn on verbose mode.\n";
    print "\n";
    print "Example: \n";
    print "> $cmd --verbose\n\n";
    print <<__EOF__;
__EOF__

    exit(0);
}

until ($site_code ne "") {
	print "Enter site code (i.e. ke1-ord): ";
	$site_code = <STDIN>;
	chomp ($site_code);
    $site_code =~s /\.//g;
    $site_code = lc($site_code);
}

my $tmp_file = "./" . ${site_code} . ".tf." . $$;
my $new_file = "./" . ${site_code} . ".tf";
if (-e $tmp_file) {
    print "\n";
	print "ERROR: File '$tmp_file' already exists!\n";
	print "       Remove this file and try again.\n\n";
	exit(1);
}
if (-e $new_file) {
    print "\n";
	print "ERROR: File '$new_file' already exists!\n";
    print "       You can not over-write an existing file.\n";
	print "       Remove this file and try again to recreate it.\n\n";
	exit(1);
}

until ($site_suburb ne "") {
	print "Enter site suburb (i.e. Wrigley): ";
	$site_suburb = <STDIN>;
	chomp ($site_suburb);
    $site_suburb =~s /\.//g;
    $site_suburb = ucfirst($site_suburb);
}

until ($site_city ne "") {
	print "Enter site city (i.e. Chicago): ";
	$site_city = <STDIN>;
	chomp ($site_city);
    $site_city =~s /\.//g;
    $site_city = ucfirst($site_city);
}

until ($site_state ne "") {
	print "Enter site state (i.e. IL): ";
	$site_state = <STDIN>;
	chomp ($site_state);
    $site_state =~s /\.//g;
    $site_state = uc($site_state);
}

until ($hardware_model ne "") {
	print "Enter hardware model (i.e. Chamber, VEM150A2, VEM180A1, VEM20A2, etc.): ";
	$hardware_model = <STDIN>;
	chomp ($hardware_model);
}

until ($datasource_uid ne "") {
    if ($verbose) {
        print "NOTE:  The 'datasource_uid' can be found in the respective datasource's url (i.e. ke1-ord -> 'https://graphs.vio.sh/datasources/edit/vzO1fZfMz')\n";
        print "                                                                                                                                     ^^^^^^^^^\n";
    }
	print "Enter datasource_uid for datasource '$site_code' (i.e. vzO1fZfMz): ";
	$datasource_uid = <STDIN>;
	chomp ($datasource_uid);
}

until ($panel_id_airflow ne "X") {
	print "Enter respective dashboard panel id for AIRFLOW (i.e. 30 - leave blank if panel not needed): ";
	$panel_id_airflow = <STDIN>;
	chomp ($panel_id_airflow);
}

until ($panel_id_humidity ne "X") {
	print "Enter respective dashboard panel id for HUMIDITY (i.e. 31 - leave blank if panel not needed): ";
	$panel_id_humidity = <STDIN>;
	chomp ($panel_id_humidity);
}

if ($panel_id_humidity ne "") {
    until ($humidity_style_prompt =~ /^[YyNn]$/) {
        print "   - Old style: max(device_humidity_avg{backend_id='$site_code',reading_type='humidity'})\n";
        print "   - New style: max(device_percentage_avg{backend_id='$site_code', device_info=~'.*network.*', reading_type='percentage', unit_name='percent'})\n";
        print "   Use old query style for humidity readings? (y/n - if not sure, type 'n'): ";
        $humidity_style_prompt = <STDIN>;
        chomp($humidity_style_prompt);
    }
    if ($humidity_style_prompt =~ /^[Yy]$/) {
        $humidity_style = "old";
    }
}

until ($panel_id_power ne "X") {
	print "Enter respective dashboard panel id for POWER (i.e. 32 - leave blank if panel not needed): ";
	$panel_id_power = <STDIN>;
	chomp ($panel_id_power);
}

until ($panel_id_pressure ne "X") {
	print "Enter respective dashboard panel id for PRESSURE (i.e. 32 - leave blank if panel not needed): ";
	$panel_id_pressure = <STDIN>;
	chomp ($panel_id_pressure);
}

until ($panel_id_temperature ne "X") {
	print "Enter respective dashboard panel id for TEMPERATURE (i.e. 33 - leave blank if panel not needed): ";
	$panel_id_temperature = <STDIN>;
	chomp ($panel_id_temperature);
}

until ($panel_id_incoming ne "X") {
	print "Enter respective dashboard panel id for INCOMING DEVICE READINGS (i.e. 68 - leave blank if panel not needed): ";
	$panel_id_incoming = <STDIN>;
	chomp ($panel_id_incoming);
}

# $site_code = "ke1-ord"
# $rule_group = "site_metrics_ke1-ord"
# $rule_group_name = "Site Metrics [KE1-ORD]"
# $site_name = "KE1-ORD - Wrigley (Chicago, IL)"
# $datasource_uid = "vzO1fZfMz"

my $rule_group = "site_metrics_" . $site_code;
my $rule_group_name = uc($site_code);
my $site_name = $rule_group_name . " - " . $site_suburb . " (" . $site_city . ", " . $site_state . ")";

if ($DEBUG) {
	print $site_code . "\n";
	print $site_suburb . "\n";
	print $site_city . "\n";
	print $site_state . "\n";
	print $site_name . "\n";
	print $rule_group . "\n";
	print $rule_group_name . "\n";
}
my $blah;

my $template_file = "./TEMPLATE_tf";
open (TEMPLATE, "<$template_file") or die "Could not open $template_file!";
open (TMP_FILE, ">$tmp_file") or die "Could not open $tmp_file!";
while (<TEMPLATE>) {
    chomp($_);
    if ($_ =~ /^    rule \{/) { 
        my $rule_line = $_;
        $_ = <TEMPLATE>;
        chomp($_);
        if ($DEBUG) {
            print "outside - $_\n";
        }
        if ($_ =~ /- Humidity/) {
            $humidity_check = 1;
        }
        if (($_ =~ /- Airflow/ && ${panel_id_airflow} eq "") ||
            ($_ =~ /- Humidity/ && ${panel_id_humidity} eq "") ||
            ($_ =~ /- Power/ && ${panel_id_power} eq "") ||
            ($_ =~ /- Pressure/ && ${panel_id_pressure} eq "") ||
            ($_ =~ /- Temperature/ && ${panel_id_temperature} eq "")) {
               until ($_ =~ /^    \}/) {
                   $_ = <TEMPLATE>;
                   chomp($_);
                   if ($DEBUG) {
                       print "inside - $_\n";
                   }
               }
               next;
        } else {
            print TMP_FILE $rule_line . "\n";
        }
    }
    if ($humidity_check == 1) {
        if ($humidity_style eq "new") {
            if ($_ =~ /expr_OLD/) { next; }
            if ($_ =~ /expr_NEW/) { $_ =~s /expr_NEW/expr/; }
        } else {
            if ($_ =~ /expr_NEW/) { next; }
            if ($_ =~ /expr_OLD/) { $_ =~s /expr_OLD/expr/; }
        }
    }
 	$_ =~s /<TEMPLATE_RULE_GROUP>/${rule_group}/;
    $_ =~s /<TEMPLATE_RULE_GROUP_NAME>/${rule_group_name}/;
    $_ =~s /<TEMPLATE_SITE_CODE>/${site_code}/;
    $_ =~s /<TEMPLATE_SITE_NAME>/${site_name}/;
    $_ =~s /<TEMPLATE_HARDWARE_MODEL>/${hardware_model}/;
    $_ =~s /<TEMPLATE_DATASOURCE_UID>/${datasource_uid}/;
	$_ =~s /<TEMPLATE_PANEL_ID_AIRFLOW>/${panel_id_airflow}/;
	$_ =~s /<TEMPLATE_PANEL_ID_HUMIDITY>/${panel_id_humidity}/;
	$_ =~s /<TEMPLATE_PANEL_ID_POWER>/${panel_id_power}/;
	$_ =~s /<TEMPLATE_PANEL_ID_PRESSURE>/${panel_id_pressure}/;
	$_ =~s /<TEMPLATE_PANEL_ID_TEMPERATURE>/${panel_id_temperature}/;
	$_ =~s /<TEMPLATE_PANEL_ID_INCOMING>/${panel_id_incoming}/;
    print TMP_FILE $_ . "\n";
}
close (TMP_FILE);
close (TEMPLATE);

move($tmp_file, $new_file) or die "Move failed: $!";

if ($verbose) {
	my @diff = `diff $template_file $new_file`;
    print "====================================================================\n";
	print "verbose mode [on]\n";
    print "====================================================================\n";
    print "Changes made: > diff $template_file $new_file:\n\n";
    foreach my $i (@diff) {
        chomp($i);
		print "$i\n";
	}
    print "\n";
    print "====================================================================\n";
}

print "\nNew alert file created:\n";
print "$new_file\n\n";

if ($verbose) {
    print "NOTE: You will need to make sure that '__dashboardUid__' and '__panelId__' are set correctly in this new alert file, otherwise alerts won't be associated properly to those entities.\n";
    print "      The '__dashboardUid__' can be found in the respective dashboard's url (i.e. 'https://graphs.vio.sh/d/xtkCtBkiz_2/website-health-preview?orgId=1&refresh=1h')\n";
    print "                                                                                                           ^^^^^^^^^^^\n";
    print "      The '__panelId__' can be found in the respective dashboard's top most panel, in the json model (i.e. ' \"id\": 138,')\n";
    print "                                                                                                                   ^^^\n\n";
}

exit(0);
