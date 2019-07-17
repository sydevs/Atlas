
const Search = {

  load() {
    document.getElementById('sidebar-button').addEventListener('click', Search._onSidebarButtonClick)
    document.getElementById('search').addEventListener('change', Search._onSearchChange)
  },

  _onSidebarButtonClick(e) {
    Sidebar.openPanel('list')
  },

  _onSearchChange(e) {

  },

}
