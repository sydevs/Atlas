/* globals Flickity */
/* exported ImageGallery */

class ImageGallery {

  constructor(element) {
    this.container = element

    this.flickity = new Flickity(element, {
      setGallerySize: false,
      lazyLoad: 2,
      imagesLoaded: true,
      contain: true,
    })
  }

  setImages(images) {
    this.container.style = images.length > 0 ? '' : 'display: none'
    this.container.classList.toggle('flickity-single', images.length == 1)

    const cells = images.map(image => {
      const img = document.createElement('IMG')
      img.className = 'carousel-image'
      img.dataset.flickityLazyloadSrc = image.thumbnail_url

      img.addEventListener('load', () => {
        this.flickity.resize()
      })

      return img
    })

    this.flickity.remove(this.flickity.getCellElements())
    this.flickity.append(cells)
    this.flickity.select(0, false, true)
    this.flickity.reloadCells()
  }

}
