require 'redcarpet'

class CMS::ConversationsController < CMS::ApplicationController

  prepend_before_action { @model = Conversation }

end
