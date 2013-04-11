#!/usr/bin/env ruby

require 'rubygems'
require 'google_calendar' # https://github.com/northworld/google_calendar
require 'builder' # For building HTML
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
    def lookup(maxResults=25)
      return event_lookup("?max-results=" + maxResults.to_s)
    end
  end
end


def getCloudEventData

  cal = Google::Calendar.new( :username => @username, :password => @password,
    :app_name => 'github.com-mcormier-StGeorgeCalendar',
    :calendar => @calendar )

  return cal.lookup(999)
end


def buildEventString(currentDay, events)

  eventString = ""

  events.each do |event|
    start = Time.parse(event.start_time)

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
  builder.div( :class => "dateRow") {
    for i in 0..6
      if currentDay.wday == i and currentDay.month == currentMonth
        val = currentDay.day.to_s
        currentDay = currentDay.next
        cssClasses = ""
      else
        val = " "
        cssClasses = "otherMonth"
      end
      builder.div( val, :class => cssClasses )
    end
  }
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

        saveCurrentDay = currentDay
        generateDateRow(x, currentDay, currentMonth)
        currentDay = saveCurrentDay

        x.div( :class => "contentRow") {

          for i in 0..6
            if currentDay.wday == i and currentDay.month == currentMonth
              val = buildEventString( currentDay, events)
              currentDay = currentDay.next
              cssOuterClasses = "outerContainer"
              cssInnerClasses = "innerContainer"
            else
              val = ""
              cssOuterClasses = "outerContainer otherMonth"
              cssInnerClasses = "innerContainer otherMonth"
            end
            
            x.div( :class => cssOuterClasses) {
                x.div( val, :class => cssInnerClasses )
            }
            
          end
        }

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

def generate(monthName, events)
  d = Date.parse ('1 '+ monthName+ ' ' + @year)
  generateMonth(d, monthName, events)
end



events = getCloudEventData()
puts "Got event data from the Google cloud.  I like fluffy clouds..."

# April until November
for i in 4..11
  monthName = Date::MONTHNAMES[i]
  generate(monthName, events)
  puts "Generated " + monthName
end

