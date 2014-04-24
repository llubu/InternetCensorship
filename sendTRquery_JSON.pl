#! /usr/bin/perl -w
use strict;
use Data::Dumper;
use JSON;

print "\n\n\t\tTraceroute measurements on RIPE ATLAS\n\n";

#	Input from user
my $testname = shift;
my $target = shift;
my $probe_ID = shift;
my $run = shift;
my $resp;
my @a_defs;
my @a_probes;

#	Prepare the measurements
my %defs;
$defs{"description"} = "Vinay_".$testname;
$defs{"af"} = 4;
$defs{"is_oneoff"} = JSON::true;
$defs{"is_public"} = JSON::true;
$defs{"resolve_on_probe"} = JSON::true;
$defs{"protocol"} = "ICMP";
$defs{"target"} = $target;
$defs{"type"} = "traceroute";
push(@a_defs, \%{defs});

#	Prepare the probe
my %probe;
$probe{"requested"} = 1;
$probe{"type"} = "probes";
$probe{"value"} = $probe_ID;
push(@a_probes,\%{probe});

#	Preparing JSON
my %JSON_REQ = (
		 'definitions' => \@{a_defs},
		 'probes' => \@{a_probes}
		);
my $JSON = to_json(\%JSON_REQ);

#	Debugging
if ($run eq "DEBUG") {
	my $dat = decode_json($JSON);
	print Dumper($dat), "\n";
}

#	Prepare the curl
my $curl = 'curl -H  "Content-Type: application/json" -H "Accept: application/json" -X POST -d';
my $url	= 'https://atlas.ripe.net/api/v1/measurement/?key=85e9eb91-cb6c-45da-826d-868a2cbc9278';

#	Print the curl
print "\n\n$curl '$JSON' $url\n\n";

#	Run the Curl
if ($run eq "SEND") {
	$resp =	`$curl '$JSON' $url`;
	print "\n\n $resp \n\n";

	my $JSON_RESP = decode_json($resp);
	print Dumper($JSON_RESP), "\n";
}

exit;
