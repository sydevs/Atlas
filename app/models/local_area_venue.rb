class LocalAreaVenue < ActiveRecord::Base

  belongs_to :local_area
  belongs_to :venue

end
