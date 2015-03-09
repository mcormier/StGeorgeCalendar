
class PPCalGenerator

  def initialize(events)
     @events = events

     # TODO -- make these hard coded values dynamic
     @year = '2015'
     @outputDir = '/Users/mcormier/Portfolio/GIT/StGeorgeCalendar/data/2015/'
  end


  def generate

    for i in 4..11
      month_name = Date::MONTHNAMES[i]
      puts "TODO generate #{month_name} "
      generate_month(month_name, @events)
    end

  end

  private
  def generate_month(month_name, events)
    first_day = Date.parse ('1 '+ month_name+ ' ' + @year)

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

  def build_event_string(current_day, events)
    days_event_list = []

    events.each do |event|
      if event.on_day?(current_day)
        # put into array so we can order them by time.
        days_event_list.push(event)
      end
    end

    event_string = ''

    # TODO -- fix sorting.
    #days_event_list = days_event_list.sort { |a,b| compare_events(a, b) }

    days_event_list.each do |event|
      # use the description
      if event_string.length > 0
        event_string = event_string + "\n\n"
      end
      event_string += event.content
    end


    event_string
  end

  # -1 if self < argument     a < b
  # 0 if self == argument
  # 1 if self > argument      a > b
  def compare_events(a, b)
    time_a = a.start_time
    time_b = b.start_time

    if time_a == time_b
      return 0
    end

    if time_a > time_b
      return 1
    end

    -1

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

end