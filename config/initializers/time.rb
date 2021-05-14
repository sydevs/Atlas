require 'active_support/core_ext/numeric'

class Time
  def floor(seconds = 60)
    Time.at((self.to_f / seconds).floor * seconds).utc
  end
end

Time::DATE_FORMATS[:month_and_date] = '%b %e'
Time::DATE_FORMATS[:short_date] = '%e %b %Y'
Time::DATE_FORMATS[:day] = '%a, %b %e'
