'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-login-modal'
  template: require './templates/transfer-cart-errors'

  initialize: ->
    super
    console.log ['model', @model]

  attach: ->
    super
    @showAsModal()
    @$('.productTable.scrollPanel').scrollpane({ parent: '.dataTable'});

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: (-> utils.redirectTo(controller: 'home', action: 'index', params: 'xxxxxx')), height:550).click()