#! /usr/bin/perl -w
use strict;
use Data::Dumper;
use JSON;

#	Title
print "\n\n\t\tDNS measurements on RIPE ATLAS\n\n";

#	Input from user
my $testname = shift;
my $resolvers_file = shift;
my $hosts_file = shift;
my $probes_file = shift;

#	Loading resolvers
my @resolvers;
open(my $fh_resl, "<", $resolvers_file)
    or die "Failed to open file: $!\n";
while(<$fh_resl>) { 
    chomp; 
    push @resolvers, $_;
} 
close $fh_resl;

#	Loading Probes
my @probes;
open(my $fh_probe, "<", $probes_file)
    or die "Failed to open file: $!\n";
while(<$fh_probe>) { 
    chomp; 
    push @probes, $_;
} 
close $fh_probe;

#	Loading hosts
my @hosts;
open(my $fh_host, "<", $hosts_file)
    or die "Failed to open file: $!\n";
while(<$fh_host>) { 
    chomp; 
    push @hosts, $_;
} 
close $fh_host;

#	Common parameters
my $desp	=	'"description": "Vinay_'.$testname.'"';
my $af		=	'"af": 4';
my $one_off	=	'"is_oneoff": true';
my $public	= 	'"is_public": true';
my $res_probe	=	'"resolve_on_probe": true';

#	Prepare the definitions
my $common	=	$desp.', '.$af.', '.$one_off.', '.$public.', '.$res_probe.', ';
my $defs	=	"";

#	Operation
foreach my $host (@hosts) {
	my $query_arg	=	'"'.$host.'"';
	my $dns_arg	=	'"query_class": "IN", "query_type": "A", "query_argument": '.$query_arg;

	foreach my $target (@resolvers) {
		my $dns	=	'"target": "'.$target.'", '.'"type": "dns", '.$dns_arg;
		if ($defs ne "") {
			$defs = $defs.', ';
		}
		$defs = $defs.'{ '.$common.$dns.' }';
	}
}

#	Prepare the probe
my $pros	=	"";
foreach my $probe (@probes) {
	if ($pros ne "") {
		$pros = $pros.', ';
	}
	$pros	= 	$pros.'{ "requested": 3, "type": "asn", "value": "'.$probe.'" }';
}

#	Prepare the curl
my $curl	=	'curl -H  "Content-Type: application/json" -H "Accept: application/json" -X POST -d';
my $definitions	=	'"definitions": [ '.$defs.' ], ';
my $probes	=	'"probes": [ '.$pros.' ]';
my $url		=	'https://atlas.ripe.net/api/v1/measurement/?key=85e9eb91-cb6c-45da-826d-868a2cbc9278';

#	Print the curl
#print "\n\n $curl '{ $definitions $probes }' $url \n\n";
my $data = "{ ".$definitions.$probes." }";
my $res = JSON->new->allow_nonref->decode($data);
print Dumper($res), "\n";

#	Run the Curl
#$resp		=	`$curl '{ $definitions $probes }' $url`;

#	Print the response
#print "\n\n $resp \n\n";

exit;
