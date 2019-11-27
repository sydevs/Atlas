module Map::ApplicationHelper

  SHARING_URLS = {
    mail: 'mailto:?subject={title}&body={url}',
    facebook: 'https://www.facebook.com/sharer.php?u={url}',
    twitter: 'https://twitter.com/intent/tweet?url={url}&text={title}',
    linkedin: 'https://www.linkedin.com/shareArticle?url={url}&title={title}&summary={text}&source={provider}',
    flipboard: 'https://share.flipboard.com/bookmarklet/popout?v=2&title={title}&url={url}',
  }.freeze

end
