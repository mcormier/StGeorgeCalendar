# St. George Calendar Generate-tron-amajig #

## What it does? ##
Grabs all the event data from a google calendar and generates an html page per month that you can include on your website.

## How it works? ##
1. Grabs all the event data from one Google calendar.
2. Generates one html page per month for our tennis season (April to October)
3. The content for each day comes from concatenating the description data. If you want an event to show up on your google calendar but not in the generated page then don't adda description.
4. To push the line break formatting to the Google description, set the csswhite-space property to pre-wrap "white-space:pre-wrap" for the innerContainer div.

## How we use it? ##

Integrated with some gross PHP to create one page with all months that slowly hides the months.

    <?php $now = date('Y-m-d');
        if ($now < date('2013-05-01') ) { include 'calendar/April.html'; }
     ?>
    <div style="clear:both;"/>
    <?php if ($now < date('2013-06-01')) { include 'calendar/May.html'; } ?>
    <div style="clear:both;"/>
    <?php if ($now < date('2013-07-01')) { include 'calendar/June.html'; } ?>
    <div style="clear:both;"/>
    <?php if ($now < date('2013-08-01')) { include 'calendar/July.html'; } ?>
    <div style="clear:both;"/>
    <?php if ($now < date('2013-09-01')) { include 'calendar/August.html'; } ?>
    <div style="clear:both;"/>
    <?php if ($now < date('2013-10-01')) { include 'calendar/September.html'; } ?>
    <div style="clear:both;"/>
    <?php if ($now < date('2013-11-01')) { include 'calendar/October.html'; } ?>
    <div style="clear:both;"/>
    <?php  include 'calendar/November.html';  ?>



## Caveats ##
- Don't use recurring events. The ruby library that is parsing the events will break.  Trust me, you probably don't really want to use a recurring event.  It sounds convenient but the exception cases will make things very complicated in some cases.

## Ubuntu installation Notes ##

- sudo apt-get update
- sudo apt-get install libxml2 libxml2-dev libxslt1-dev
- sudo gem install nokogiri
- sudo gem install google\_calendar
- Copy config.properties.example and call it config.properties.  Modify accordingly.

