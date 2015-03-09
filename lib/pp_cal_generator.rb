
class PPCalGenerator

  def initialize(events)
     @events = events
  end


  def generate

    for i in 4..11
      month_name = Date::MONTHNAMES[i]
      puts "TODO generate #{month_name} "
    end

  end



end