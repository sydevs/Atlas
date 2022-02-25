/* global $ */
/* exported ManagerSearch */

const ManagerSearch = {
  load() {
    this.$card = $('#js-manager-card')
    this.$search = $('#js-manager-search')
    this.$fields = $('#js-manager-fields')
    this.$inputs = $('#js-manager-fields [name]')

    this.$search.search({
      type: 'category',
      minCharacters: 3,
      apiSettings: {
        url: '/cms/managers.json?q={query}',
      },
      onSelect: (result, _response) => {
        this.$card.toggleClass('blue', result.category == 'manager')
        this.$card.toggleClass('green', result.category == 'invite')
        this.$card.find('.header').text(result.alt_title || result.title)
        this.$card.find('.meta').text(result.description)

        this.$search.search('set value', '')
        this.$search.search('hide results')
        this.$search.removeClass('loading')

        this.$inputs.each((index, field) => {
          if (field.name == 'event[manager_id]') {
            field.value = result.id
            return
          }

          const key = field.name.match(/^event\[manager_attributes\]\[(.+)\]$/)[1]
          const value = result[key] || field.dataset.default || ''
          
          if (field.tagName == 'SELECT') {
            const $dropdown = $(field).parent()
            $dropdown.dropdown('set exactly', [value])
            $dropdown.toggleClass('disabled', result.category != 'invite')
            $(field).prop('disabled', result.category != 'invite')
          } else {
            field.value = value
            $(field).prop('disabled', key == 'id' || result.category != 'invite')
          }
        })

        if (result.category == 'invite') {
          this.$fields.accordion('open', 0)
        }

        this.$card.show()
        return false
      }
    })
  }
}

$(document).on('ready', function() {
  if ($('#js-manager-search').length > 0) {
    ManagerSearch.load()
  }
})
