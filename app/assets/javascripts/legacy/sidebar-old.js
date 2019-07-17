
const Sidebar = {
  instance: null,

  init() {
    console.log('loading sidebar.js')
    Sidebar.instance = L.control.sidebar({
      autopan: true,
      closeButton: true,
      container: 'sidebar', // the DOM container or #ID of a predefined sidebar container that should be used
      position: 'left', // left or right
    }).addTo(Map.instance)

    $('.venues-item').click(event => {
      let id = $(event.currentTarget).data('id')
      Sidebar.show_venue(Map.data[id])
    })

    $('.venue-events-list').on('click', '.venue-events-item', event => {
      Sidebar.show_event($(event.currentTarget).data('event'))
    })

    document.getElementById('zoom-in').onclick = () => { if (!$(this).hasClass('disabled')) Map.zoom_in() }
    document.getElementById('zoom-out').onclick = () => { if (!$(this).hasClass('disabled')) Map.zoom_out() }
    document.getElementById('reset').onclick = () => { if (!$(this).hasClass('disabled')) Map.reset() }
    Map.instance.on('zoomend', Sidebar._on_zoom_end)
  },

  show_venue(venue) {
    $venue = $('#venue')
    $venue.children('.venue-title').text(venue.name)
    $venue.children('.venue-address').text(venue.full_address)

    $events = $venue.children('.venue-events-list')
    $events.empty()
    venue.events.forEach(event => {
      let $event = Map.event_template.clone()
      $event.children('.venue-events-title').text(event.name)
      $event.children('.venue-events-category').text(event.category)
      $event.children('.venue-events-timing').text(event.timing)

      event.address = venue.full_address
      $event.data('event', event)
      $events.append($event)
    })

    Sidebar.instance.disablePanel('event').enablePanel('venue').open('venue')
    Map.set_highlight_marker(venue.marker, true)
  },

  show_event(event) {
    $event = $('#event')
    $event.children('.event-title').text(event.name)
    $event.children('.event-address').text(event.address)
    $event.children('.event-category').text(event.category)
    $event.children('.event-timing').text(event.timing)
    $event.children('.event-description').text(event.description)
    $('#registration-event').val(event.id)

    if (event.room != null) {
      $event.children('.event-room').text(event.room)
    }

    Sidebar.instance.enablePanel('event').open('event')
  },

  _on_zoom_end() {
    let zoom = Map.instance.getZoom()
    $('#zoom-in-button').toggleClass('disabled', zoom == Map.instance.getMaxZoom())
    $('#zoom-out-button').toggleClass('disabled', zoom == Map.instance.getMinZoom())
    $('#reset-button').toggleClass('disabled', zoom == Map.initial_zoom)
  },
}
