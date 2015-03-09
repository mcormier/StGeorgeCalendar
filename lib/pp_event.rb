
class PPEvent

  def initialize(event, occurrences)
    @event = event
    @occurrences = occurrences
  end

  def on_day?(day)
    #(day >= self.start_date and day <= self.end_date )
    false
  end
end