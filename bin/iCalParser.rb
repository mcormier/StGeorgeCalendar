#!/usr/bin/env ruby


require_relative '../lib/stgeorgecal'



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

pp_events = Array.new

events.each do |event|

  occurrences = event.occurrences_between(Date.parse('2015-01-01'), Date.parse('2015-12-01'))
  pp_event = PPEvent.new(event, occurrences)
  pp_events.push pp_event

  if event.summary == 'TGIF Tennis'
    puts event.summary
    puts "DTSTART: #{event.dtstart}"
    puts "DTEND: #{event.dtstart}"
    puts "occurrences: #{occurrences.length}"
    puts ''

    occurrences.each do |occurs|
      puts "#{occurs.start_time}"
    end
  end

end


generator = PPCalGenerator.new(pp_events)
generator.generate