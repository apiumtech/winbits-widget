template = require 'views/templates/widget/address'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class AddressView extends View
  autoRender: no
  #className: 'home-page'
  container: '#headerAddress'
  template: template

  render: ->
    console.log "ಠ_ಠ"
    super

  initialize: ->
    super
    @delegate 'click', '#updateBtnAdress', @saveDireccion
    @delegate 'click', '#editBtnAddress', @editAddress


  editAddress: (e)->
    console.log "---->"
    @$el.find(".miDireccion").slideUp()
    @$el.find(".editMiDireccion").slideDown()

  saveDireccion: (e)->
    e.preventDefault()
    e.stopPropagation()
    console.log "ProfileView#saveProfile"

  attach: ->
    super

