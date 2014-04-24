#! /usr/bin/perl
use MIME::Base64;
use Net::DNS;
use Net::DNS::Packet;
use Data::Dumper;
use JSON;
use strict;

while (my $result = shift) {

	my $json = `curl -s https://atlas.ripe.net/api/v1/measurement/$result/result/?format=json`;
	my $text_j = decode_json($json);
	#print Dumper($text_j);
	#next;
	my $text = $$text_j[0];
	my $dst_addr = $text->{"dst_addr"};
	my $from = $text->{"from"};
	my $prb_id = $text->{"prb_id"};
	my $tstamp = $text->{"timestamp"};
	my $msmid = $text->{"msm_id"};
	my $result = $text->{"result"};
		print "begin\nverbose\n";
	for my $record (@$result) {
		#print Dumper($record), "\n";
		my $hop = $record->{"hop"};
		my $res = $record->{"result"};
		my $from = "";
		for my $p (@$res) {
			next if ($from eq $p->{"from"});
			#print $hop.",\t".
			print $p->{"from"}."\n";
			$from = $p->{"from"};
		}
	}
		print "end\n";
}
