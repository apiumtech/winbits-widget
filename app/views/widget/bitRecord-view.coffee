template = require 'views/templates/widget/bitsCredit'
View = require 'views/base/view'
util = require 'lib/util'

module.exports = class BitRecordView extends View
  autoRender: false
  #className: 'home-page'
  container: '#historial'
  template: template

  render: ->
    super

  initialize: ->
    super
    #@delegate 'click', '#updateBtnAdress', @saveDireccion
    #@delegate 'click', '#editBtnAddress', @editAddress
    @subscribeEvent 'bitRecordReady', @handlerModelReady

  editAddress: (e)->
    @$el.find(".miDireccion").slideUp()
    @$el.find(".editMiDireccion").slideDown()

  saveDireccion: (e)->
    e.preventDefault()
    e.stopPropagation()
    console.log "ProfileView#saveProfile"

  attach: ->
    super

  handlerModelReady: ->
      console.log '++++++++++++ Listo!!!!!!'
      @render()
