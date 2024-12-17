require "montrose"

module Recurrable

  extend ActiveSupport::Concern

  FIELDS = %i[type start_date end_date start_time end_time]

  RECURRENCES = {
    daily: { every: :day, interval: 1 }, # Daily
    weekly_1: { every: :week, interval: 1 }, # Weekly
    weekly_2: { every: :week, interval: 2 }, # Bi-Weekly
    monthly_1st: { every: :month, interval: 1 }, # 1st week of month
    monthly_2nd: { every: :month, interval: 1 }, # 2nd week of month
    monthly_3rd: { every: :month, interval: 1 }, # 3rd week of month
    monthly_4th: { every: :month, interval: 1 }, # 4th week of month
    monthly_last: { every: :month, interval: 1 }, # last week of month
  }

  RECURRENCE_ORDINAL = {
    monthly_1st: 1, # 1st week of month
    monthly_2nd: 2, # 2nd week of month
    monthly_3rd: 3, # 3rd week of month
    monthly_4th: 4, # 4th week of month
    monthly_last: -1, # last week of month
  }

  included do
    store :recurrence_data, accessors: FIELDS, prefix: :recurrence
    validate :validate_end_time
    validate :validate_end_date
  end

  def first_recurrence_at
    recurrence.first.utc if recurrence.present?
  end

  def next_recurrence_at
    upcoming_recurrences(limit: 1).first&.utc if recurrence.present?
  end

  def last_recurrence_at
    return nil unless recurrence&.finite?

    recurrence.events.to_a.last&.utc
  end

  def upcoming_recurrences(limit: 7)
    return [] if recurrence.nil? || recurrence.later?(Time.now)

    result = recurrence.fast_forward(Time.now).take(limit + 1)
    if result.first < Time.now
      result.drop(1).map(&:utc)
    else
      result.take(limit).map(&:utc)
    end
  end

  def recurrence
    @recurrence ||= begin
      return nil unless recurrence_data && recurrence_data[:type].present? 

      Time.use_zone(time_zone) do
        rd = recurrence_data
        type = rd[:type].to_sym
        data = RECURRENCES[type].clone
        
        if rd[:start_date].present?
          data[:starts] = rd[:start_date]
          data[:until] = rd[:end_date]
          data[:at] = rd[:start_time]
          weekday = rd[:start_date].to_date.strftime("%A")&.downcase&.to_sym

          if Recurrable::RECURRENCE_ORDINAL.key?(type)
            data.merge!(day: { weekday => Recurrable::RECURRENCE_ORDINAL[type] })
          elsif type != :daily
            data.merge!(on: weekday)
          end
        end

        Montrose.recurrence(data)
      end
    end
  end

  def duration
    return nil unless recurrence_end_time&.present?
  
    start_time = recurrence_start_time.split(':').map(&:to_f)
    end_time = recurrence_end_time.split(':').map(&:to_f)
    (end_time[0] - start_time[0]) + ((end_time[1] - start_time[1]) / 60.0)
  end

  private
    
    def validate_end_time
      return unless recurrence_end_time.present?
      return if recurrence_start_time.present? && duration.positive?
      
      self.errors.add(:end_time, I18n.translate('cms.messages.event.invalid_end_time'))
    end

    def validate_end_date
      return unless recurrence_data[:end_date].present?
      
      self.errors.add(:end_date, I18n.translate('cms.messages.event.invalid_end_date')) if recurrence.ends_at < recurrence.starts_at
      # self.errors.add(:end_date, I18n.translate('cms.messages.event.passed_end_date')) if end_date < Date.today
    end

end
