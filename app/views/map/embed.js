
document.addEventListener('DOMContentLoaded', function() {
  const params = new URLSearchParams(location.search)
  const script = document.currentScript
  const iframe = document.createElement('IFRAME')
  iframe.src = `https://${location.host}/map${script.getAttribute('path')}?key=${script.getAttribute('key')}`
  iframe.width = '100%'
  iframe.border = 0
  iframe.addEventListener('load', function() {
    document.title = iframe.contentDocument.title
  })

  script.replaceWith(iframe)
})  
