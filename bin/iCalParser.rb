#!/usr/bin/env ruby

require 'icalendar'
require 'icalendar/recurrence'
require 'builder'

require_relative 'lib/common.rb'

script_location = File.expand_path File.dirname(__FILE__)
to_load = script_location + '/../config/config.properties'
load to_load


cal_file = File.open(script_location + '/../data/ical/2015_mar_8.ics')

# An array of Icalendar::Calendar.  For our purposes the ics file contains only
# one calendar.
calendars = Icalendar.parse(cal_file)

calendar = calendars[0]

# Returns an array of Icalendar::Event
events = calendar.events

events.each do |event|
  puts event.summary
  puts "DTSTART: #{event.dtstart}"
  puts "DTEND: #{event.dtstart}"
  puts ''
end

puts "Number of events #{events.length}"

# This returns an Icalendar::Event
#event = Array(calendars).first.events.first # retrieve the first event

# get all occurrence for one month
#blah = event.occurrences_between(Date.parse('2015-03-01'), Date.parse('2015-09-01'))

#puts blah.length

#puts blah[0].start_time
#puts blah[0].end_time

#puts event
#puts event.description
#puts event.summary