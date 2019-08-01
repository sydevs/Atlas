class Event < ApplicationRecord

  nilify_blanks
  belongs_to :venue
  has_many :registrations
  enum category: { intro: 1, intermediate: 2, course: 3, public_event: 4, concert: 5 }
  enum recurrence: { day: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }

  validates :name, length: { maximum: 255 }
  validates :category, presence: true
  validates :start_date, presence: true
  validates :start_time, presence: true
  validates :recurrence, presence: true
  validates :description, length: { minimum: 20, maximum: 255, allow_nil: true }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true, message: 'must be a valid email' }

  delegate :address, to: :venue

  def label
    name || category_name
  end

  def category_name
    case category
    when 'intro'
      'Intro Meditation Class'
    when 'intermediate'
      'Intermediate Meditation Class'
    when 'course'
      'Meditation Course'
    when 'public_event'
      'Stall at Public Event'
    when 'concert'
      'Meditation & Music Concert'
    end
  end

  def category_description
    case category
    when 'intro'
      'The first introductions to this kind of meditation.'
    when 'intermediate'
      'A going deeper class for those who have already attended an introductory class.'
    when 'course'
      'A several week course that takes you through various techniques of meditation.'
    when 'public_event'
      'Offering free meditation instruction at a public event.'
    when 'concert'
      'A performance combining meditation and music or dance.'
    end
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
