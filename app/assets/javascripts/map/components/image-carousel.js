/* exported ImageCarousel */
/* global m, Flickity */

function ImageCarousel() {
  let flickity

  return {
    oncreate: function(vnode) {
      const images = vnode.attrs.images

      if (images.length > 1) {
        flickity = new Flickity('#images', {
          setGallerySize: false,
          lazyLoad: 2,
          imagesLoaded: true,
          contain: true,
        })
      }
    },
    onremove: function() {
      flickity.resize()
    },
    onupdate: function(vnode) {
        console.log("DOM updated")
    },
    view: function(vnode) {
      const images = vnode.attrs.images

      return m('.sya-image-carousel#images', images.map(function(image) {
        return m('img', {
          //'data-flickityLazyloadSrc': image.url,
          src: image.url,
          onload: () => { if (flickity) flickity.resize() }
        })
      }))
    }
  }
}