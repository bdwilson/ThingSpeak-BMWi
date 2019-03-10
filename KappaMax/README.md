BMWi ThingSpeak Battery Kappa Max tracking
=======
<br>
These scripts allow you to track your daily and monthly mileage in your BMWi
automobile. 
Installation
------------
- This depends on [BMW-i3-Status](https://github.com/pkimconsulting/BMW-i3-Status) need to get this going before you move forward.
Go to the bottom of this and change the code so it just spits out the Kappa Max value and comment out all the other stuff.
<code>
echo "$battery_kappa\n";
#echo "BMW i3 Status Currently at $percentage ($eMiles / $rexMiles) Battery Kappa: $battery_kappa  Location: $address Charging State: $chargingState";
#if ($percentage == 'onte') {
#  mail($email, 'BMW i3 Status', 'Vehicle in Motion. Battery Kappa: ' . $battery_kappa . '. Location: ' . $address);
#}
#else {
#  mail($email, 'BMW i3 Status', 'Currently at ' . $percentage . '. Battery Kappa: ' . $battery_kappa . '. Location: ' . $address);
#}
</code>

- You also need a [ThingSpeak](https://thingspeak.com) account. It is free and you have plenty of "free" messages (3 million/yr) to support this app.

Once you've done these, edit kappa.pl with the location to your BMW-i3-Status
php script and your API key for Thingspeak channel (see below).

Next, create 1 channel
1) BMW i3 kWh Max - Make public in Channel Settings (you'll need the channel # and READ and WRITE API keys for the Perl script). 
- Field 1: kWh
2) Go to API keys and generate/get the WRITE key.  Put this into the perl
script above. 

Setup a cron job to run this however often you wish to get the kWh max value:
<pre>
59 23 * * * /home/user/bin/kappa.pl 1>/dev/null 2>&1 &
</pre>

Contact Info
-----------------
Bug me on Twitter at [@brianwilson](http://twitter.com/brianwilson) or email me [here](http://cronological.com/comment.php?ref=bubba).

