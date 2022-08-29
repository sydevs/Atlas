/* exported EventMetadata */

/* global m */

const EventMetadata = {
  view: function(vnode) {
    const event = vnode.attrs.event
    const registerable = Boolean(event.timing.nextDateTime)
    const dateTime = registerable ? event.timing.nextDateTime : event.timing.firstDateTime

    const data = {
      '@type': 'Event',
      'name': event.label,
      'description': event.description,
      'startDate': dateTime.toISO({ suppressSeconds: true }),
      'endDate': event.timing.duration ? dateTime.plus({ hours: event.timing.duration }).toISO({ suppressSeconds: true }) : null,
      'eventAttendanceMode': `https://schema.org/${event.online ? 'Online' : 'Offline'}EventAttendanceMode`,
      'eventStatus': 'https://schema.org/EventScheduled',
      'image': event.images.map(img => img.url),
      'organizer': {
        '@type': 'Organization',
        'name': 'We Meditate',
        'url': 'https://wemeditate.com',
      },
      'offers': {
        '@type': 'Offer',
        'url': window.location.href + '#registration',
        'price': '0',
        'priceCurrency': 'USD',
        'availability': registerable ? 'https://schema.org/InStock' : 'https://schema.org/SoldOut',
      },
      'location': event.online ? {
        '@type': 'VirtualLocation',
        'name': event.location.label,
        'url': event.onlineUrl,
      } : {
        '@type': 'Place',
        'name': event.location.label,
        'address': {
          '@type': 'PostalAddress',
          //'streetAddress': event.venue.street,
          //'addressLocality': 'Snickertown',
          //'postalCode': '19019',
          //'addressRegion': 'PA',
          //'addressCountry': 'US'
        }
      }
    }

    return m(Metadata, { data: data })
  }
}
