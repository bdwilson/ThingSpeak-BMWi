BMWi ThingSpeak Mileage Tracking
=======
<br>
These scripts allow you to track your daily and monthly mileage in your BMWi
automobile. 

![](https://github.com/bdwilson/bdwilson.github.io/blob/master/images/i3graph1.png?raw=true)

Installation
------------
- This depends on [BMW-i-Remote](https://github.com/edent/BMW-i-Remote). You
  need to get this going before you move forward.

- You also need a [ThingSpeak](https://thingspeak.com) account. It is free and
  you have plenty of "free" messages (3 million/yr) to support this app.

- If you want to track Kappa Max (max kWh), see [here](https://github.com/bdwilson/ThingSpeak-BMWi/tree/master/KappaMax).

Once you've done these, copy bmwmiles.py to your python directory inside BMW-i-Remote. Run it and make sure you can get the # of miles for your car. If not, then you need to fix that first.

Next, create two ThingSpeak channels
1) BMW i3 Daily Miles - Make public in Channel Settings (you'll need the channel # and READ and WRITE API keys for the Perl script)
- Field 1: Miles Driven
- Field 2: Cumulative Monthly
2) BMW i3 Monthly Miles - make public in Channel Settings (you'll need the write API key for the Perl script)
- Field 1: Monthly Miles

Continue to follow the comments in the script to where you want to store your previous number of miles. You can pre-populate this with current # of miles before you run it, otherwise it'll look like you drove "current number of miles" in 1 day. 

Run the script and make sure your "Daily" ThingSpeak channel has data.  If it doesn't, you'll need to figure out why. Was there output from bmwmiles.py?

Next, create your Apps in ThingSpeak. You'll need both channel numbers for the channels you created and READ API keys for both channels. I'd make these all public apps, so you can link them in an HTML page. Then go to Apps -> Plugins -> New and select "Chart with Multiple Series". Go to the Javascript portion and make sure data looks similar to this (notice this is a single series and I comment you the 2nd addSeries call):
<pre> 
  // variables for the first series
  var series_1_channel_id = [daily channel id];
  var series_1_field_number = 1;
  var series_1_read_api_key = '[daily read API key]';
  var series_1_results = 60;
  var series_1_color = '#d62020';

  // chart title
  var chart_title = 'BMW Daily Miles';
  // y axis title
  var y_axis_title = 'Values';
  // user's timezone offset
  var my_offset = new Date().getTimezoneOffset();
  // chart variable
  var my_chart;

  // when the document is ready
  $(document).on('ready', function() {
    // add a blank chart
    addChart();
    // add the first series
    addSeries(series_1_channel_id, series_1_field_number, series_1_read_api_key, series_1_results, series_1_color);
    // add the second series
    //addSeries(series_2_channel_id, series_2_field_number, series_2_read_api_key, series_2_results, series_2_color);
  });
</pre>
Add another "Chart with Multiple Series" for Cumlative Monthly Miles (again, comment out 2nd addSeries call, also notice we select field 2 on this one):
<pre>

// variables for the first series
  var series_1_channel_id = [daily channel id];
  var series_1_field_number = 2;
  var series_1_read_api_key = '[daily read API key]';
  var series_1_results = 31;
  var series_1_color = '#d62020';

  // chart title
  var chart_title = 'BMW Cumulative Daily Miles';
  // y axis title
  var y_axis_title = 'Values';

  // user's timezone offset
  var my_offset = new Date().getTimezoneOffset();
  // chart variable
  var my_chart;

  // when the document is ready
  $(document).on('ready', function() {
    // add a blank chart
    addChart();
    // add the first series
    addSeries(series_1_channel_id, series_1_field_number, series_1_read_api_key, series_1_results, series_1_color);
    // add the second series
    //addSeries(series_2_channel_id, series_2_field_number, series_2_read_api_key, series_2_results, series_2_color);
  });
</pre>
Add another "Chart with Multiple Series" for Monthly Miles (again, comment out the 2nd addSeries call):
<pre>
  // variables for the first series
  var series_1_channel_id = [monthly channel id];
  var series_1_field_number = 1;
  var series_1_read_api_key = '[monthly read API key]';
  var series_1_results = 31;
  var series_1_color = '#d62020';

  // chart title
  var chart_title = 'BMW Monthly Miles';
  // y axis title
  var y_axis_title = 'Values';

  // user's timezone offset
  var my_offset = new Date().getTimezoneOffset();
  // chart variable
  var my_chart;

  // when the document is ready
  $(document).on('ready', function() {
    // add a blank chart
    addChart();
    // add the first series
    addSeries(series_1_channel_id, series_1_field_number, series_1_read_api_key, series_1_results, series_1_color);
    // add the second series
    //addSeries(series_2_channel_id, series_2_field_number, series_2_read_api_key, series_2_results, series_2_color);
  });
</pre>

Once you have your public apps created, you can directly link to them in an
HTML page. Each plugin will have a number, and can be accessed publically by
putting that number into the links below. Create an html page and put this in your contents:
<pre>
<iframe width="825" height="425" style="border: 1px solid #cccccc;" src="https://thingspeak.com/plugins/[plugin #1]" ></iframe>
<iframe width="825" height="425" style="border: 1px solid #cccccc;" src="https://thingspeak.com/plugins/[plugin #2]" ></iframe>
<iframe width="825" height="425" style="border: 1px solid #cccccc;" src="https://thingspeak.com/plugins/[plugin #3]" ></iframe>
</pre>

- Next, install a cronjob on your server to run your script at 11:59 every
  evening. 
<pre>
59 23 * * * /home/user/bin/thingspeak-bmw.pl 1>/dev/null 2>&1 &
</pre>

FAQ
----
1) Your graphs run 14th to the 13th of the month, not 1st to end of month.
That's because my lease runs 14 to 13th, so I want to track miles that way.  If
you want to do the same thing, adjust the logic in the date piece in the Perl
script. This is what mine looks like, so adjust accordingly.
<pre>
$dom = UnixDate('today','%d');
my $day= UnixDate('today','%Y-%m');

if ($dom > 13) {
	$first_day = $day . "-14";
	$last_day= UnixDate('today','%Y-%m-%d');
} elsif ($dom < 13) {
	$last_month_last_day = DateCalc($day, "-1 day");
	$first_day = UnixDate($last_month_last_day, "%Y-%m");
	$first_day=$first_day . "-14";
	$last_day= UnixDate('today','%Y-%m-%d');
} else {
	$last_month_last_day = DateCalc($day, "-1 day");
	$first_day = UnixDate($last_month_last_day, "%Y-%m");
	$first_day=$first_day . "-14";
	$last_day=$day . "-13";
}
</pre>

Bugs/Contact Info
-----------------
Bug me on Twitter at [@brianwilson](http://twitter.com/brianwilson) or email me [here](http://cronological.com/comment.php?ref=bubba).

