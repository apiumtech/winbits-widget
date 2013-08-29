template = require 'views/templates/widget/address'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class AddressView extends View
  autoRender: yes
  #className: 'home-page'
  container: '#headerAddress'
  template: template

  render: ->
    super

  initialize: ->
    super
    @delegate 'click', '#updateBtnAdress', @saveDireccion
    @delegate 'click', '#editBtnAddress', @editAddress
    @delegate 'click', ".changeAddressBtn", @changeAddress

  editAddress: (e)->
    @$el.find(".miDireccion").slideUp()
    @$el.find(".editMiDireccion").slideDown()

  saveDireccion: (e)->
    e.preventDefault()
    e.stopPropagation()
    console.log "ProfileView#saveProfile"

  attach: ->
    super

  changeAddress: (e) ->
    e.preventDefault()
    $ = Backbone.$
    $main = $('main').first()
    $('div.dropMenu').slideUp()
    $shippingAddressContainer = $main.find('#shippingAddressMain')
    if $shippingAddressContainer.css('display') is 'none'
      $main.find('div.wrapper').hide()
      $shippingAddressContainer.show()
      @publishEvent 'showShippingAddresses'