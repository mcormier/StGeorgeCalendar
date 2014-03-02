#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'google_calendar'     # https://github.com/northworld/google_calendar
require 'builder'             # For building HTML
require 'date'
require 'time'

load '../config/config.properties'

ENV["TZ"] = @timezone

#
# Add some convenience methods to the google_calendar gem
#
module Google
  class Event
    def startDate
      if @startDate.nil?
        startTime = Time.parse(self.start_time)
        @startDate = Date.parse(startTime.strftime('%Y/%m/%d'))
      end
      return @startDate
    end

    def endDate
      if @endDate.nil?
        endTime = Time.parse(self.end_time)
        @endDate = Date.parse(endTime.strftime('%Y/%m/%d'))

        # All day events end at midnight on the next day
        # which is totally wrong
        if self.all_day?
          @endDate = @endDate.prev_day
        end
      end
      return @endDate
    end

    def onDay?(day)
      return (day >= self.startDate and day <= self.endDate) 
    end
  end

  class Calendar
    # By default Google only returns 25 results at a time.
    # This allows us to grab everything in one go
    def lookup(max_results=25)
      event_lookup("?max-results=" + max_results.to_s)
    end

  end
end


def get_cloud_event_data

  cal = Google::Calendar.new( :username => @username, :password => @password,
    :app_name => 'github.com-mcormier-StGeorgeCalendar',
    :calendar => @calendar )

  cal.lookup(999)
end


def buildEventString(currentDay, events)

  eventString = ""

  events.each do |event|
    if event.onDay?(currentDay)
      # use the description
      if eventString.length > 0 
        eventString = eventString + "\n\n" 
      end
      eventString += event.content
    end

  end

  return eventString 
end

# <div class="dateRow">
#   <div class="otherMonth"> </div>
#   <div>1</div>
#   ...
# </div>
def generateDateRow(builder, currentDay, currentMonth)
  day = currentDay

  builder.div( :class => "dateRow") {
    for i in 0..6
      if day.wday == i and day.month == currentMonth
        val = day.day.to_s
        day = day.next
        cssClasses = ""
      else
        val = " "
        cssClasses = "otherMonth"
      end
      builder.div( val, :class => cssClasses )
    end
  }
end

# <div class="contentRow">
#   <div class="outerContainer">
#     <div class="innerContainer">Event Info</div>
#   </div>
#   ...
# </div>
def generateContentRow(builder, currentDay, currentMonth, events)

  day = currentDay  

  builder.div( :class => "contentRow") {
    for i in 0..6
      if day.wday == i and day.month == currentMonth
        val = buildEventString( day, events)
        day = day.next
        cssOuterClasses = "outerContainer"
        cssInnerClasses = "innerContainer"
      else
        val = ""
        cssOuterClasses = "outerContainer otherMonth"
        cssInnerClasses = "innerContainer otherMonth"
      end
      
      builder.div( :class => cssOuterClasses) {
          builder.div( val, :class => cssInnerClasses )
      }
    end
  }

  return day
end

def generateMonth( firstDay, monthName, events )
  x = Builder::XmlMarkup.new( :indent => 2 )

  currentDay = firstDay
  currentMonth = firstDay.month

  File.open( @outputDir + monthName + ".html", "w") do |out|
    # <div id="April" class="month">
    out.puts x.div( :id => monthName, :class => "month") {
      outputHeaderAndWeekDays(x, firstDay)
     
      while currentDay.month == currentMonth
        generateDateRow(x, currentDay, currentMonth)
        currentDay = generateContentRow(x, currentDay, currentMonth, events)
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
def outputHeaderAndWeekDays(x, firstDay)
  monthHeader = Date::MONTHNAMES[firstDay.month] +" "+ firstDay.year.to_s
  x.div( monthHeader, :class => "monthHeader" )  
    x.div( :class => "weekDays") {
      Date::DAYNAMES.each { |day| x.div day }
    } 
end

def generate(month_name, events)
  d = Date.parse ('1 '+ month_name+ ' ' + @year)
  generateMonth(d, month_name, events)
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

