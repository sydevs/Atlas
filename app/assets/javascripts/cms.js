/* global $ */

//= require jquery
//= require rails-ujs
//= require semantic-ui
//= require_tree ./cms

(function() {
  if ($) {
    var token = $( 'meta[name="csrf-token"]' ).attr( 'content' )

    $.ajaxSetup( {
      beforeSend: function ( xhr ) {
        xhr.setRequestHeader( 'X-CSRF-Token', token )
      }
    })     
  }
})()
