require 'redcarpet'

class CMS::AuditsController < CMS::ApplicationController

  prepend_before_action { @model = Audit }

end
