#!/usr/bin/env ruby

require 'rubygems'
# reference: https://github.com/northworld/google_calendar
require 'google_calendar'
require 'nokogiri'
require 'builder'
require 'date'
require 'time'

load '../config/config.properties'

ENV["TZ"] = @timezone




class MyCal < Google::Calendar 

  # By default Google only returns 25 results at a time.
  # This allows us to grab everything in one go
  def lookup()
    event_lookup("?max-results=999")
  end

end



def getCloudEventData

  cal = MyCal.new( :username => @username, :password => @password,
    :app_name => 'github.com-mcormier-StGeorgeCalendar',
    :calendar => @calendar )

  events = cal.lookup()

  events
end


def eventOnDay(event, day)
    startTime = Time.parse(event.start_time)
    endTime = Time.parse(event.end_time)

    startDate = Date.parse(startTime.strftime('%Y/%m/%d'))
    endDate = Date.parse(endTime.strftime('%Y/%m/%d'))

    # All day events end at midnight on the next day
    # which is totally wrong
    if event.all_day?
      endDate = endDate.prev_day
    end

   return (day >= startDate and day <= endDate) 
end


def getEventString(currentDay, events)

  eventString = ""

  events.each do |event|
    start = Time.parse(event.start_time)

    if eventOnDay(event, currentDay)
      # use the description
      if eventString.length > 0 
        eventString = eventString + "\n\n" 
      end
      eventString += event.content
    end

  end

  eventString 
end

def generateMonth( firstDay, monthName, events )
  x = Builder::XmlMarkup.new( :indent => 2 )
  # i.e. "April 2013"
  monthHeader = Date::MONTHNAMES[firstDay.month] + " " + firstDay.year.to_s

  currentDay = firstDay
  currentMonth = firstDay.month

  File.open( @outputDir + monthName + ".html", "w") do |out|
    out.puts x.div( :id => monthName, :class => "month") {
      outputHeaderAndWeekDays(x, monthHeader)

     
      while currentDay.month == currentMonth

        saveCurrentDay = currentDay
 
        x.div( :class => "dateRow") {

          for i in 0..6
            if currentDay.wday == i and currentDay.month == currentMonth
              val = currentDay.day.to_s
              currentDay = currentDay.next
              cssClasses = ""
            else
              val = " "
              cssClasses = "otherMonth"
            end

            x.div( val, :class => cssClasses )
          end

        }

       currentDay = saveCurrentDay

        x.div( :class => "contentRow") {

          for i in 0..6
            if currentDay.wday == i and currentDay.month == currentMonth
              val = getEventString( currentDay, events)
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

def outputHeaderAndWeekDays(x, monthHeader)
      x.div( monthHeader, :class => "monthHeader" )  
      x.div( :class => "weekDays") {
        Date::DAYNAMES.each { |day|
          x.div day
        }
      } 
end

def generate(monthName, events)
  d = Date.parse ('1 '+ monthName+ ' ' + @year)
  generateMonth(d, monthName, events)
  puts "Generated " + monthName
end

events = getCloudEventData
puts "Got Event Data from the Google cloud.  I like fluffy clouds."

generate("April", events)
generate("May", events)
generate("June", events)
generate("July", events)
generate("August", events)
generate("September", events)
generate("October", events)
generate("November", events)


