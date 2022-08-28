class AreaVenue < ActiveRecord::Base

  belongs_to :area
  belongs_to :venue

end
