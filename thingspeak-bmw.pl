#!/usr/bin/perl
# Keep track of BMWiX Mileage 

use JSON;
use Data::Dumper;
use LWP::Simple qw($ua get);
use Date::Manip;

use Net::SSL (); # From Crypt-SSLeay
BEGIN {
  $Net::HTTPS::SSL_SOCKET_CLASS = "Net::SSL"; # Force use of Net::SSL
}

# Create Two ThingSpeak channels
# 1) BMW i3 Daily Miles - Make public in Channel Settings
#    Field 1: Miles Driven
#    Field 2: Cumulative Monthly
#    Put Channel # in %channels hash along with the READ API key
%channels = ("2937xx"=>"0254UZCP6L4xxxx");
#    Put write key below
$write_key_daily="ZE9JN73BPDMxxxx";
# 2) BMW i3 Monthly Miles - make public in Channel Settings. 
#    Field 1: Monthly Miles
#    Put Channel API write key below. 
$write_key_monthly="Q142LHI4YCNxxxxx";
# Location to store last mile count. you may want to pre-populate with
# the current # of miles on your car (just digits), if you do this, you'll just
# be tracking deltas from here on out. 
$data_file="/home/wilson/.bmwmiles-dev.dat";
# install location of BMW-i-Remote python scripts
$bmwi_dir="/home/wilson/code/BMW-i-Remote/python";
# also copy my bmwmiles.py script there
$bmwi_miles="/home/wilson/code/BMW-i-Remote/python/bmwmiles.py";

open(DAT, "$data_file");
while(<DAT>) {
	chomp;
	$miles = $_;
}
close(DAT);

$diff=0;
chdir "$bmwi_dir";
open(MILES, "$bmwi_miles|");
while(<MILES>) {
	chomp;
	s/\,//g;
	if (/(^\d+)/) {
		$new_miles = $1;
	}
	if ($new_miles != $miles) {
		$diff=$new_miles-$miles;
	}
}

$dom = UnixDate('today','%d');
$day= UnixDate('today','%Y-%m');
$m = UnixDate('today','%m');
$y = UnixDate('today','%y');
$days = Date_DaysInMonth($m,$y);

$first_day = $day . "-01";
$last_day = $day . "-$days";
	
foreach $channel (keys %channels) {
	$key = $channels{$channel};
	$miles=0;
	$count=0;

	$curl=`curl -s -k \"http://api.thingspeak.com/channels/$channel/feed.json?start=$first_day%2000:00:01&end=$last_day%2023:59:59&days=1&timezone=America%2FNew_York\"`;
	my $coder = JSON::XS->new->utf8->pretty->allow_nonref;
	my $item = $coder->decode ($curl);
	my $feed= $item->{'feeds'};

	$feed = [$feed] if (ref $feed eq 'HASH');

	foreach my $i (@$feed) {
		foreach $item (keys %$i) {
			if ($item eq "field1") {
				$miles= $miles+ ($i->{$item});
				$count++;
			}
		}
	}
}
$miles = $miles + $diff;
if ($dom eq $days) {
	$data=$data . "&field1=" . $miles;
	$url = "http://api.thingspeak.com/update?key=$write_key_monthly" . $data;
	$content=get($url);
}

if ($diff > 0) {
    $data="&field1=$diff&field2=$miles";
    $url = "http://api.thingspeak.com/update?key=$write_key_daily" .  $data;
    $content=get($url);
	open(DAT, ">$data_file");
	print DAT $new_miles;
	close(DAT);
}

