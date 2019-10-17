
module Mail::ApplicationHelper

  def message content, format = :html, type = :default
    if format == :html
      content_tag :blockquote, class: (type == :default ? 'message' : "message--#{type}") do
        concat tag.strong(content[:title], class: 'title')
        concat tag.p(content[:description])
      end
    else
      capture do
        concat content[:title]
        concat "\r\n"
        concat '=' * content[:title].length
        concat "\r\n"
        concat content[:description]
      end
    end
  end

end
