#!/usr/bin/env ruby

require 'optparse'
require_relative '../lib/stgeorgecal'



script_location = File.expand_path File.dirname(__FILE__)
to_load = script_location + '/../config/config.properties'
load to_load

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: iCalParser.rb [options]'

  opts.on('-t', '--test', 'Adds style sheet to generated files for testing') do |t|
    options[:test] = t
  end
end.parse!

ENV['TZ'] = @timezone

cal_file = File.open(@ical_file)

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

  if event.summary == 'Annual General Meeting'
    puts event.summary
    puts "DTSTART: #{event.dtstart}"
    puts "DTEND: #{event.dtstart}"
    puts "occurrences: #{occurrences.length}"
    puts "duration: #{event.duration}"
    puts ''

    occurrences.each do |occurs|
      puts "Start time: #{occurs.start_time}"
      puts "End time: #{occurs.end_time}"
      puts "End time: #{occurs.end_time.class}"
      puts "End time: #{occurs.end_time - 1}"
    end
  end

end


generator = PPCalGenerator.new(pp_events)

if options[:test]
  generator.test_mode=true
end

generator.output_dir = @output_dir

generator.generate
