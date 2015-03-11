
def safe_require( gemName, gemVersion )

  begin
    gem gemName, "=#{gemVersion}"
    require gemName
  rescue LoadError
    puts " Missing #{gemName} gem"
    puts " Try: gem install #{gemName} -v #{gemVersion}"
    exit
  end

end

safe_require('icalendar', '2.2.0')  # https://github.com/icalendar/icalendar

require 'icalendar/recurrence'

require 'builder'
require 'date'

require_relative 'pp_cal_generator'
require_relative 'pp_event'