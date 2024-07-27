module MessageChannel

  extend ActiveSupport::Concern

  included do
    has_many :messages, as: :channel
    # Create a scope which left outer joins with the last message and compare the ID to the manager id
    # scope :message_outstanding, -> { where('events.finish_date IS NULL OR events.finish_date >= ?', DateTime.now) }
  end

  def message_outstanding?
    messages.last.received_messageable == manager
  end

  def default_message_receiver
    raise "'default_message_receiver' method is not implemented"
  end

  def send_message from, **kwargs
    kwargs[:channel] = self

    if messages.present?
      from.reply_to(messages.last, **kwargs)
    else
      from.send_message(default_message_receiver, **kwargs)
    end
  end

end