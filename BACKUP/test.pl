#! /usr/bin/perl

#	Title
print "\n\n\t\tMeasurement on RIPE ATLAS\n\n";

#	Input from user
$testname = shift;
$type = shift;

#	Common parameters
$desp		=	'"description": "Vinay_'.$testname.'"';
$af		=	'"af": 4';
$one_off	=	'"is_oneoff": true';
$public		= 	'"is_public": true';
$res_probe	=	'"resolve_on_probe": true';

#	Prepare the definitions
$common		=	$desp.', '.$af.', '.$one_off.', '.$public.', '.$res_probe.', ';
$defs		=	"";

#	Operation
if ($type eq "ping")	{

	while (my $input = shift) {
		$ping	= 	'"target": '.'"'.$input.'"'.', '.'"type": "ping"';

		if ($defs ne "") {
			$defs = $defs.', ';
		}
		$defs = $defs.'{ '.$common.$ping.' }';
	}

} elsif ($type eq "dns") {

	while (my $input = shift) {
		@resolvers	=	('"61.166.150.123"', '"125.219.48.8"', '"156.154.71.1"');
		#@resolvers	=	('"156.154.71.1"', '"208.67.220.220"');
		$query_type	=	'"A", ';
		$query_arg	=	'"'.$input.'"';
		$dns_arg	=	'"query_class": "IN", '.'"query_type": '.$query_type.'"query_argument": '.$query_arg;

		foreach my $target (@resolvers) {
			$dns	=	'"target": '.$target.', '.'"type": "dns", '.$dns_arg;
#"use_probe_resolver": true,
			if ($defs ne "") {
				$defs = $defs.', ';
			}
			$defs = $defs.'{ '.$common.$dns.' }';
		}
	}

} else {
	print "Input Error !!!";
	exit;
}

#	Prepare the probe
$pros		= 	'"requested": 3, "type": "country", "value": "US"';

#	Prepare the curl
$curl		=	'curl -H  "Content-Type: application/json" -H "Accept: application/json" -X POST -d';
$definitions	=	' "definitions": [ '.$defs.' ], ';
$probes		=	' "probes": [ { '.$pros.' } ] ';
$url		=	'https://atlas.ripe.net/api/v1/measurement/?key=85e9eb91-cb6c-45da-826d-868a2cbc9278';

#	Print the curl
print "\n\n $curl '{ $definitions $probes }' $url \n\n";

#	Run the Curl
$resp		=	`$curl '{ $definitions $probes }' $url`;

#	Print the response
print "\n\n $resp \n\n";

#	Backup
#$resp=`curl -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{ "definitions": [ { "target": "ripe.net", "description": "My First Measurement", "type": "ping", "af": 4 } ], "probes": [ { "requested": 50, "type": "area", "value": "WW" } ] }' https://atlas.ripe.net/api/v1/measurement/?key=85e9eb91-cb6c-45da-826d-868a2cbc9278`;
