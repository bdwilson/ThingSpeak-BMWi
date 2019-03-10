#!/usr/bin/perl
$bmwi3status="/home/user/code/BMW-i3-Status/bmwi3status.php";
$kappa_api_key="xxxxxxxxxxxxx";

open(KAPPA, "/usr/bin/php $bmwi3status|");
while(<KAPPA>) {
		chomp;
		$kappa_max=$_;
}
close(KAPPA);

if ($kappa_max > 0) {
	$url = "https://api.thingspeak.com/update?api_key=$kappa_api_key&field1=$kappa_max";
	$content=`curl -s -k \"$url\"`;
	print "$content\n";
}
