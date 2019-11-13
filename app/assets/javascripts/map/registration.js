/* global */
/* exported Registration */

const Registration = {
  load() {
    console.log('loading registration.js') // eslint-disable-line no-console

    $('.event-registration').submit(Registration._on_submit)
  },

  _on_submit() {
    let id = document.getElementById('registration-event').value
    let xhttp = new XMLHttpRequest()
    let data = new FormData(this)
    console.log(this, data)

    for (var [key, value] of data.entries()) {
      console.log(key, value)
    }

    xhttp.onreadystatechange = function() {
      console.log('update', this.readyState, this.status)
      if (this.readyState == 4 && this.status == 200) {
        let response = JSON.parse(this.response)
        console.log(response)
        $('#registration-message').toggleClass('negative', response.status == 'error')
        $('#registration-message').toggleClass('positive', response.status == 'success')
        document.getElementById('registration-message').innerText = response.message
      }
    }

    xhttp.open('POST', `/events/${id}/registrations`, true)
    //xhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
    xhttp.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name=csrf-token]').getAttribute('content'))
    xhttp.send(data)
    return false
  },

  submit() {
    let xhttp = new XMLHttpRequest()
    let id = document.getElementById('registration-event').value
    let name = document.getElementById('registration-name').value
    let email = document.getElementById('registration-email').value
    let comment = document.getElementById('registration-comment').value

    console.log('submit registration', [
      'registration[name]=', name,
      '&registration[email]=', email,
      '&registration[comment]=', comment,
    ])

    xhttp.onreadystatechange = function() {
      console.log('update', this.readyState, this.status)
      if (this.readyState == 4 && this.status == 200) {
        console.log(this.readyState)
      }
    }

    xhttp.open('POST', `/events/${id}/registrations`, true)
    xhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
    xhttp.send([
      'registration[name]=', name,
      '&registration[email]=', email,
      '&registration[comment]=', comment,
    ].join(''))
  },
}
