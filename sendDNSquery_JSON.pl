#! /usr/bin/perl -w
use strict;
use Data::Dumper;
use JSON;

print "\n\n\t\tDNS measurements on RIPE ATLAS\n\n";

#	Input from user
my $testname = shift;
my $resolvers_file = shift;
my $hosts_file = shift;
my $probes_file = shift;
my $run = shift;

#	Initializations
my @defs;
my @pbs;
my $resp;
my @resolvers;
my @probes;
my @hosts;

#	Loading resolvers
open(my $fh_resl, "<", $resolvers_file)
    or die "Failed to open file: $!\n";
while(<$fh_resl>) { 
    chomp; 
    push @resolvers, $_;
} 
close $fh_resl;

#	Loading Probes
open(my $fh_probe, "<", $probes_file)
    or die "Failed to open file: $!\n";
while(<$fh_probe>) { 
    chomp; 
    push @probes, $_;
} 
close $fh_probe;

#	Loading hosts
open(my $fh_host, "<", $hosts_file)
    or die "Failed to open file: $!\n";
while(<$fh_host>) { 
    chomp; 
    push @hosts, $_;
} 
close $fh_host;

#	Prepare the measurements
foreach my $host (@hosts) {
	foreach my $target (@resolvers) {
		my %temp;
		$temp{"description"} = "Vinay_".$testname;
		$temp{"af"} = 4;
		$temp{"is_oneoff"} = JSON::true;
		#$temp{"one_off"} = JSON::true;
		$temp{"is_public"} = JSON::true;
		$temp{"resolve_on_probe"} = JSON::true;
		$temp{"query_class"} = "IN";
		$temp{"query_type"} = "A";
		$temp{"query_argument"} = $host;
		$temp{"target"} = $target;
		$temp{"type"} = "dns";
		push(@defs, \%{temp});
	}
}

#	Prepare the probe
foreach my $probe (@probes) {
	my %temp1;
	$temp1{"requested"} = 20;
	#$temp1{"type"} = "area";
	$temp1{"type"} = "country";
	$temp1{"value"} = $probe;
	push(@pbs, \%{temp1});
}

#	Preparing JSON
my %JSON_REQ = (
		 'definitions' => \@defs,
		 'probes' => \@pbs
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
