
class PPEvent

  def initialize(event, occurrences)
    @event = event
    @occurrences = occurrences
  end

  def on_day?(day)

    if @occurrences.length > 0
      # TODO loop through occurrences and return true if start_time end_time works...

      @occurrences.each do |occurs|
        if day >= occurs.start_time.to_date and day <= occurs.end_time.to_date
          return true
        end
      end

    end

    # TODO -- if 0 occurrences need other logic.

    #(day >= self.start_date and day <= self.end_date )
    false
  end


  def content
    @event.summary
  end

end