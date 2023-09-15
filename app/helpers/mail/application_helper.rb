module Mail::ApplicationHelper

  STATUS_ICONS = {
    created: 'created',
    needs_review: 'alert',
    needs_urgent_review: 'alert',
    expired: 'expired',
    finished: 'verified',
  }.freeze

  STATUS_COLORS = {
    created: '#21ba45',
    needs_review: '#f2711c',
    needs_urgent_review: '#db2828',
    expired: '#db2828',
    finished: '#1e5b82',
  }.freeze

  STAT_ICONS = {
    new_registrations: 'registration',
    active_events: 'verified',
    active_countries: 'country',
    active_regions: 'location',
  }

  def email_image_tag(image, **options)
    if defined?(attachments)
      attachments[image] = File.read(Rails.root.join("app/assets/images/#{image}"))
      image_tag attachments[image].url, **options
    else
      image_tag image
    end
  end

  def email_login(url)
    defined?(@template_link) ? @template_link + url : url
  end

  def email_status_icon(status)
    content_tag :div, class: 'alert' do
      content_tag :div, class: 'alert__box', style: "background: #{STATUS_COLORS[status]}" do
        content_tag :div, class: 'alert__icon' do
          image_tag "mail/#{STATUS_ICONS[status]}-white.png", width: 28, height: 28
        end
      end
    end
  end

  def percent_difference(val, old_val)
    if val == old_val
      diff = 0
    elsif val.zero?
      diff = -100
    elsif old_val.zero?
      diff = +100
    else
      diff = (val.to_f / old_val.to_f * 100).to_i - 100
    end
  end

  def time_from_now_in_words time
    time > Time.now ? time_ago_in_words(time) : translate('datetime.distance_in_words.soon')
  end

end
