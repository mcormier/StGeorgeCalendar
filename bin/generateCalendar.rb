#!/usr/bin/env ruby

#noinspection RubyResolve

require 'rubygems'
require 'optparse'
require 'google_calendar'     # https://github.com/northworld/google_calendar
require 'builder'             # For building HTML
require 'date'
require 'time'

load '../config/config.properties'

ENV['TZ'] = @timezone

#
# Add some convenience methods to the google_calendar gem
#


module Google

  class Event

    def start_date
      if @start_date.nil?
        time = Time.parse(self.start_time)
        @start_date = Date.parse(time.strftime('%Y/%m/%d'))
      end

      @start_date
    end

    def end_date
      if @end_date.nil?
        end_time = Time.parse(self.end_time)

        @end_date = Date.parse(end_time.strftime('%Y/%m/%d'))

        # All day events end at midnight on the next day
        # which is totally wrong
        if self.all_day?
          @end_date = @end_date.prev_day
        end
      end

      @end_date
    end

    def on_day?(day)
      (day >= self.start_date and day <= self.end_date )
    end

    # https://github.com/northworld/google_calendar/issues/27
    def all_day?
      case @start_time
        when String
          time = Time.parse(@start_time)
        else
          time = @start_time
      end

      duration % (24 * 60 * 60) == 0 && time == Time.local(time.year,time.month,time.day)
    end

  end

  class Calendar
    # By default Google only returns 25 results at a time,
    # this method allows us to grab everything in one go.
    def lookup(max_results=25)
      event_lookup('?max-results=' + max_results.to_s)
    end

  end
end


def get_cloud_event_data

  cal = Google::Calendar.new( :username => @username, :password => @password,
    :app_name => 'github.com-mcormier-StGeorgeCalendar',
    :calendar => @calendar )

  cal.lookup(999)
end


def build_event_string(current_day, events)

  event_string = ''

  events.each do |event|
    if event.on_day?(current_day)
      # use the description
      if event_string.length > 0
        event_string = event_string + "\n\n"
      end
      event_string += event.content
    end

  end

  event_string
end

# <div class="dateRow">
#   <div class="otherMonth"> </div>
#   <div>1</div>
#   ...
# </div>
def generate_date_row(builder, current_day, current_month)
  day = current_day

  builder.div( :class => 'dateRow') {
    for i in 0..6
      if day.wday == i and day.month == current_month
        val = day.day.to_s
        day = day.next
        css_classes = ''
      else
        val = ' '
        css_classes = 'otherMonth'
      end
      builder.div( val, :class => css_classes )
    end
  }
end

# <div class="contentRow">
#   <div class="outerContainer">
#     <div class="innerContainer">Event Info</div>
#   </div>
#   ...
# </div>
def generate_content_row(builder, current_day, current_month, events)

  day = current_day

  builder.div( :class => 'contentRow') {
    for i in 0..6
      if day.wday == i and day.month == current_month
        val = build_event_string( day, events)
        day = day.next
        css_outer_classes = 'outerContainer'
        css_inner_classes = 'innerContainer'
      else
        val = ''
        css_outer_classes = 'outerContainer otherMonth'
        css_inner_classes = 'innerContainer otherMonth'
      end
      
      builder.div( :class => css_outer_classes) {
          builder.div( val, :class => css_inner_classes )
      }
    end
  }

  day
end

def generate_month( first_day, month_name, events )
  x = Builder::XmlMarkup.new( :indent => 2 )

  current_day = first_day
  current_month = first_day.month

  File.open( @outputDir + month_name + '.html', 'w') do |out|
    # <div id="April" class="month">
    out.puts x.div( :id => month_name, :class => 'month') {
      output_header_and_week_days(x, first_day)
     
      while current_day.month == current_month
        generate_date_row(x, current_day, current_month)
        current_day = generate_content_row(x, current_day, current_month, events)
      end
    }
  end
end

# Generates:
#   <div class="monthHeader">April 2013</div>
#   <div class="weekDays">
#     <div>Sunday</div>
#     ...
#     </div>Saturday</div>
#   </div>
#
def output_header_and_week_days(x, first_day)
  month_header = Date::MONTHNAMES[first_day.month] + ' ' + first_day.year.to_s
  x.div( month_header, :class => 'monthHeader')
    x.div( :class => 'weekDays') {
      Date::DAYNAMES.each { |day| x.div day }
    } 
end

def generate(month_name, events)
  d = Date.parse ('1 '+ month_name+ ' ' + @year)
  generate_month(d, month_name, events)
end



options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: generateCalendar.rb [options]'

  opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
    options[:verbose] = v
  end
end.parse!




events = get_cloud_event_data
if options[:verbose]
  puts '==========================================='
  puts 'Begin events received from the fluffy cloud'
  puts events
  puts 'End events received from fluffy cloud'
  puts '==========================================='
end

puts 'Got event data from the Google cloud.  I like fluffy clouds...'


# April until November
for i in 4..11
  month_name = Date::MONTHNAMES[i]
  generate(month_name, events)
  puts "Generated #{month_name}"
end

