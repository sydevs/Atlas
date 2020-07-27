require 'active_support/core_ext/numeric'

class Time
  def floor(seconds = 60)
    Time.at((self.to_f / seconds).floor * seconds).utc
  end
end