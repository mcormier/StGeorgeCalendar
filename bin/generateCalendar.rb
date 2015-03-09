#!/usr/bin/env ruby

#noinspection RubyResolve

require 'rubygems'
require 'optparse'

begin
  gem 'google_calendar', '=0.4.4'     
  require 'google_calendar'     # https://github.com/northworld/google_calendar
rescue LoadError
  puts ' Missing google calendar gem'
  puts ' Try: gem install google_calendar -v 0.4.4'
  exit
end

require 'builder'             # For building HTML
require 'date'
require 'time'

require 'pry'

load '../config/config.properties'

ENV['TZ'] = @timezone

#
# Add some convenience methods to the google_calendar gem
#


module Google

=begin
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

    def self.<=>(b)
      -1
    end

  end

=end

=begin
  class Calendar
    # By default Google only returns 25 results at a time,
    # this method allows us to grab everything in one go.
    def lookup(max_results=25)
      event_lookup('?max-results=' + max_results.to_s)
    end

  end
=end


end

# -1 if self < argument     a < b
# 0 if self == argument
# 1 if self > argument      a > b
def compare_google_events(a, b)
  time_a = Time.parse(a.start_time)
  time_b = Time.parse(b.start_time)

  if time_a == time_b
    return 0
  end

  if time_a > time_b
    return 1
  end

  -1

end


def get_cloud_event_data

# Google now requires a client id.
# https://github.com/northworld/google_calendar/blob/master/lib/google/calendar.rb
#
# Create one here --> https://console.developers.google.com/
#
#

  cal = Google::Calendar.new( 
    :client_id => @client_id,
    :client_secret => @client_secret,
    :redirect_url => 'urn:ietf:wg:oauth:2.0:oob',
    :calendar => @calendar )

#  puts "Do you already have a refresh token? (y/n)"
#  has_token = $stdin.gets.chomp

  #if has_token.downcase != 'y'
    # A user needs to approve access in order to work with their calendars.
    puts "Visit the following web page in your browser and approve access."
    puts cal.authorize_url
    puts "\nCopy the code that Google returned and paste it here:"
  
    # Pass the ONE TIME USE access code here to login and get a refresh token 
    # that you can use for access from now on.
    refresh_token = cal.login_with_auth_code( $stdin.gets.chomp )
  


  #cal.lookup(999)
  cal.events
end


def build_event_string(current_day, events)
  days_event_list = []

  events.each do |event|
    if event.on_day?(current_day)
      # put into array so we can order them by time.
      days_event_list.push(event)
    end
  end

  event_string = ''

  days_event_list = days_event_list.sort { |a,b| compare_google_events(a, b) }

  days_event_list.each do |event|
    # use the description
    if event_string.length > 0
      event_string = event_string + "\n\n"
    end
    event_string += event.content
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

if events.nil?
  puts '==========================================='
  puts ' No events found exiting ...'
  puts '==========================================='
  exit
end


if options[:verbose]
  puts '==========================================='
  puts 'Begin events received from the fluffy cloud'
  puts events
  puts 'End events received from fluffy cloud'
  puts '==========================================='
end

puts 'Got event data from the Google cloud.  I like fluffy clouds...'


# March until November
for i in 2..11
  month_name = Date::MONTHNAMES[i]
  generate(month_name, events)
  puts "Generated #{month_name}"
end

