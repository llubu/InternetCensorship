#! /usr/bin/perl
use MIME::Base64;
use Net::DNS;
use Net::DNS::Packet;
use Data::Dumper;
use JSON;
use strict;

while (my $result = shift) {

	my $json = `curl -s https://atlas.ripe.net/api/v1/measurement/$result/result/?format=json`;
	my $text = decode_json($json);
	#print Dumper($text),"\n";
	#next;
	in: for my $record (@$text) {
		my $abuf = $record->{"result"}->{"abuf"};
		my $dst_addr = $record->{"dst_addr"};
		my $from = $record->{"from"};
		my $prb_id = $record->{"prb_id"};
		my $tstamp = $record->{"timestamp"};
		my $msmid = $record->{"msm_id"};
		#print Dumper($record), "\n";
		#next;
		if($abuf ne "") {
			my $data = decode_base64($abuf);
			my $packet = Net::DNS::Packet->new(\$data, 0);
			my @ans = $packet->answer;
			my @ques = $packet->question;
			#print Dumper($packet), "\n";
			#next;
			if ((scalar @ans) == 0) {	
				next in;
				print $msmid.",\t".
				$tstamp.",\t".
				$dst_addr.",\t".
				$from.",\t".
				$prb_id.",\t".
				@ques[0]->name.",\t".
				"NO_ANSWER"."\n";
			} else {
				foreach my $answ (@ans) {
					if ($answ->type eq "A") {
						print $msmid.",\t".
						$tstamp.",\t".
						$dst_addr.",\t".
						$from.",\t".
						$prb_id.",\t".
						@ques[0]->name.",\t".
						$answ->address."\n";
					}	
                       		}
			}
		}
	}
}
