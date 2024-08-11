require 'redcarpet'

class CMS::ConversationsController < CMS::ApplicationController

  prepend_before_action { @model = Conversation }

  def set_scope!
    if @context.is_a?(Event)
      @scope = @context.conversations.or(Conversation.active.where(parent: @context.registrations))
      puts "SET SCOPE #{@scope}"
    else
      super
    end
  end

end
