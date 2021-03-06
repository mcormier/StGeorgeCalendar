
class PPEvent

  def initialize(event, occurrences)
    @event = event
    @occurrences = occurrences
  end

  def on_day?(day)

    if @occurrences.length > 0
      # TODO loop through occurrences and return true if start_time end_time works...

      # Subtract 1 second from end_time because all day events end at midnight on the
      # next day.
      @occurrences.each do |occurs|

        start_date = occurs.start_time.getlocal.to_date
        end_date = (occurs.end_time.getlocal - 1).to_date

        if day >= start_date and day <= end_date
          return true
        end

      end

    end

    # TODO -- if 0 occurrences need other logic.

    #(day >= self.start_date and day <= self.end_date )
    false
  end


  def start_time_for(day)

    @occurrences.each do |occurs|

      start_date = occurs.start_time.getlocal.to_date
      end_date = (occurs.end_time.getlocal - 1).to_date

      if day >= start_date and day <= end_date
        return occurs.start_time
      end

    end

    # Return a really old date if this event doesn't occur on that day
    Time.new(2002)

  end

  def content
    @event.description
  end

  def start_time
    @event.dtstart
  end

end