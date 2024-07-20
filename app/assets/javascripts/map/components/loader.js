/* exported EventCard */
/* global m, Util */

function Loader() {
  return {
    view: function(vnode) {
      const size = vnode.attrs.type || 'large'
      const error = vnode.attrs.error
      return m(`.sya-loader.sya-loader--${size} ${error ? 'sya-loader--error' : null}`, [
        m('.sya-spinner'),
        size == 'small' ? error || Util.translate('list.loading') : null,
      ])
    }
  }
}
