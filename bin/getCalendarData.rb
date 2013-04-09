#!/usr/bin/env ruby

require 'rubygems'
# reference: https://github.com/northworld/google_calendar
require 'google_calendar'
require 'nokogiri'

require 'builder'
require 'date'
require 'time'
# If the timezone isn't set properly an event
# could show up on two days since the time shift
# puts it on two days.
ENV["TZ"] = "America/Halifax"


load '../config/config.properties'


class MyCal < Google::Calendar 

  # By default Google only returns 25 results at a time.
  # This allows us to grab everything in one go
  def lookup()
    event_lookup("?max-results=999")
  end

end

def getCloudEventData

  cal = MyCal.new(
    :username => @username,
    :password => @password,
    :app_name => 'mycompany.com-googlecalendar-integration',
    :calendar => @calendar
  )

  events = cal.lookup()

  events
end


COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
#
# The St. George Calendar runs from April to Oct
# So we can use constants and not worry about leap
# years in February
#
def getDaysInMonth(month)
  if month == 2
    raise "February and leap years not supported!!"
  end 
  COMMON_YEAR_DAYS_IN_MONTH[month]
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

  daysInMonth = getDaysInMonth(firstDay.month)
  
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
              cssClasses = "innerContainer"
            else
              val = ""
              cssClasses = "innerContainer otherMonth"
            end
            
            x.div( :class => "outerContainer") {
                x.div( val, :class => cssClasses )
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
puts "Got Event Data"

#generate("April", events)
#generate("May", events)
#generate("June", events)
#generate("July", events)
#generate("August", events)
generate("September", events)


