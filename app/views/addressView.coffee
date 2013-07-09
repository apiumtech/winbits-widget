template = require 'views/templates/address'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class AddressView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#headerAddress'
  template: template

  render: ->
    console.log "ಠ_ಠ"
    super

  attach: ->
    super
    util.openFolder
      obj: ".myAddress .miDireccion"
      trigger: ".myAddress .miDireccion .editBtn, .myAddress .miDireccion .changeAddressBtn"
      objetivo: ".myAddress .editMiDireccion"

    util.openFolder
      obj: ".myAddress .editMiDireccion"
      trigger: ".myAddress .editMiDireccion .editBtn"
      objetivo: ".myAddress .miDireccion"

