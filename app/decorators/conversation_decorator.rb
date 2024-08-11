module ConversationDecorator

  def label
    translate_model(Conversation)
    # "#{translate_model(Conversation)} ##{id}"
  end

end