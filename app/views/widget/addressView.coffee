template = require 'views/templates/widget/address'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class AddressView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#headerAddress'
  template: template

  render: ->
    console.log "ಠ_ಠ"
    console.log @$
    super

  attach: ->
    super
    util.openFolder Backbone.$,
      obj: ".myAddress .miDireccion"
      trigger: ".myAddress .miDireccion .editBtn, .myAddress .miDireccion .changeAddressBtn"
      objetivo: ".myAddress .editMiDireccion"

    util.openFolder Backbone.$,
      obj: ".myAddress .editMiDireccion"
      trigger: ".myAddress .editMiDireccion .editBtn"
      objetivo: ".myAddress .miDireccion"

