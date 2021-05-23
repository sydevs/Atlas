module Summary

  extend ActiveSupport::Concern

  included do
    self.class::SUMMARY_PERIOD = 1.day if ENV['TEST_EMAILS']
  end

  def set_summary_period!
    if self.class::SUMMARY_PERIOD >= 1.month
      @start_of_period = self.class::SUMMARY_PERIOD.ago.beginning_of_month
      @end_of_period = self.class::SUMMARY_PERIOD.ago.end_of_month
    elsif self.class::SUMMARY_PERIOD >= 1.week
      @start_of_period = self.class::SUMMARY_PERIOD.ago.beginning_of_week
      @end_of_period = self.class::SUMMARY_PERIOD.ago.end_of_week
    else
      @start_of_period = self.class::SUMMARY_PERIOD.ago.beginning_of_day
      @end_of_period = self.class::SUMMARY_PERIOD.ago.end_of_day
    end
  end

  def last_summary_too_soon? datetime
    cooldown_interval = self.class::SUMMARY_PERIOD - (self.class::SUMMARY_PERIOD >= 1.week ? 1.day : 6.hours)
    return false if datetime <= cooldown_interval.ago

    puts "[MAIL] Skip sending summary email"
    true
  end

end
