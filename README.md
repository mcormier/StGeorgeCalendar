# St. George Calendar Generate-tron-amajig #

## What it does? ##
Grabs all the event data from a google calendar and generates an html page per month that you can include on your website.

## How it works? ##
1. Grabs all the event data from one Google calendar.
2. Generates one html page per month for our tennis season (April to October)
3. The content for each day comes from concatenating the description data. If you want an event to show up on your google calendar but not in the generated page then don't adda description.
4. To push the line break formatting to the Google description, set the csswhite-space property to pre-wrap "white-space:pre-wrap" for the innerContainer div.

## Caveats ##
- Don't use recurring events. The ruby library that is parsing the events will break.  Trust me, you probably don't really want to use a recurring event.  It sounds convenient but the exception cases will make things very complicated in some cases.

## Ubuntu installation Notes ##

- sudo apt-get update
- sudo apt-get install libxml2 libxml2-dev libxslt1-dev
- sudo gem install nokogiri
- sudo gem install google\_calendar
- Copy config.properties.example and call it config.properties.  Modify accordingly.

