View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class CompleteRegisterView extends View
  autoRender: yes
  container: '#wbi-modals-holder'
  template: require 'views/templates/widget/complete-register-tranfer-bits'

  initialize: ->
    super
    @subscribeEvent 'completeRegister', @showCompleteRegisterModal
    @delegate 'click', '#wbi-close-complete-register', @onCloseCompleteRegister

  attach: ->
    super
    console.log ['MODAL', @$el]
    @$el.find('.modal').modal(show: false)


  showCompleteRegisterModal: (cashback) ->
    Winbits.$('div.dropMenu').slideUp()
    Winbits.$('.modal').modal('hide')

    @$el.find('.modal').modal('show').css(
      width: '625px',
      'margin-left': -> -( Winbits.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  Winbits.$( this ).height() / 2 )
    ).find('.wb-cashback').text(cashback).closest('.wb-modal-holder').show()

  onCloseCompleteRegister: ->
    @$el.closest('.wb-modal-holder').hide()
