

const Uploader = {
  instance: null,

  load() {
    this.list = document.getElementById('uploaded-images')
    this.template = document.getElementById('upload-template')

    this.instance = Uppy.Core({
      autoProceed: true,
      restrictions: {
        allowedFileTypes: ['image/*'],
      }
    })

    this.instance.use(Uppy.Dashboard, {
      trigger: '#upload-button',
      showProgressDetails: true,
      browserBackButtonClose: true,
      // closeAfterFinish: true,
    })

    this.instance.use(Uppy.Webcam, {
      countdown: false,
      modes: ['picture'],
      facingMode: 'environment',
      locale: {},
      target: Uppy.Dashboard,
    })

    this.instance.use(Uppy.XHRUpload, {
      endpoint: document.getElementById('upload-button').dataset.endpoint,
    })

    this.instance.on('upload-success', (file, response) => {
      const $element = $(this.template.content).clone()
      $element.find('a.view.label').attr('href', response.url)
      $element.find('a.destroy.label').attr('href', response.delete_url)
      $element.find('img').attr('src', response.thumbnail_url)
      this.list.append($element[0])
    })

    $('.destroy.label').on('click', event => {
      let element = event.currentTarget.children[0]
      if (element.classList.contains('loading')) {
        event.stopPropagation()
        event.preventDefault()
      } else {
        element.classList.remove('close')
        element.classList.add('spinner')
        element.classList.add('loading')
        event.currentTarget.style.cursor = 'default'
      }
    })
  },
}

$(document).on('ready', function() {
  if ($('#upload-button').length > 0) {
    Uploader.load()
  }
})
