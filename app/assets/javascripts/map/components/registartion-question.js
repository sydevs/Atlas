/* exported RegistrationQuestion */
/* global m, autosize */

function RegistrationQuestion() {
  let textarea

  return {
    oncreate: function(vnode) {
      autosize(textarea.dom)
    },
    view: function(vnode) {
      question = vnode.attrs.question
      textarea = m('textarea.sya-registration__textarea', {
        onchange: event => vnode.attrs.onchange(event),
        rows: 1,
      })

      return [
        m('label', question.title),
        textarea
      ]
    }
  }
}