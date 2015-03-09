#!/usr/bin/env ruby

require 'icalendar'
require 'builder'

require_relative 'lib/common.rb'

script_location = File.expand_path File.dirname(__FILE__)
to_load = script_location + '/../config/config.properties'
load to_load


cal_file = File.open(script_location + '/../data/ical/2015_mar_8.ics')
events = Icalendar.parse(cal_file)


for i in 2..11
  month_name = Date::MONTHNAMES[i]
  generate(month_name, events)
  puts "Generated #{month_name}"
end

