class Event < ApplicationRecord

  include Manageable
  
  nilify_blanks
  belongs_to :venue
  has_many :registrations
  mount_uploaders :images, ImageUploader
  enum category: { intro: 1, intermediate: 2, course: 3, public_event: 4, concert: 5 }
  enum recurrence: { day: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }

  validates :name, length: { maximum: 255 }
  validates :category, presence: true
  validates :start_date, presence: true
  validates :start_time, presence: true
  validates :recurrence, presence: true
  validates :description, length: { minimum: 20, maximum: 255, allow_nil: true }

  delegate :full_address, to: :venue

  def label
    name || category_name
  end

  def languages= value
    # Only accept languages which are in the language list
    super value & I18nData.languages.keys
  end

  def address
    { room: room }.merge(venue.address)
  end

  def category_name
    I18n.translate(category, scope: %i[category title])
  end

  def category_description
    I18n.translate(category, scope: %i[category description])
  end

  def timing
    result = ''

    if start_date == end_date || (end_date.nil? and recurrence == 'day')
      result += start_date.to_s(:short)
    elsif recurrence == 'day'
      result += "#{start_date.to_s(:short)} - #{end_date.to_s(:short)}"
    else
      result += "Every #{recurrence.humanize.titleize}"
    end

    result += ", #{start_time}"
    result += " - #{end_time}" if end_time
    result
  end

  def next_date
    date = nil

    if start_date == end_date || (end_date.nil? and recurrence == 'day')
      date = start_date
    elsif recurrence == 'day'
      date = [start_date, Date.today].min
    else
      date = date_of_next(recurrence)
    end

    date.to_s
  end

  private

    def date_of_next day
      date = Date.parse(day)
      delta = date > Date.today ? 0 : 7
      date + delta
    end

end
