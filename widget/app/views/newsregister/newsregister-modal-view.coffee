$ = Winbits.$
View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class NewsregisterModalView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-newsregister-modal'
  template: require './templates/newsregister-modal-view'

  initialize: ->
    super
    @delegate 'click', '#wbi-go-login-button', @onLoginButtonClick

  attach: ->
    super
    @showAsModal()



  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> ).click()

  onLoginButtonClick: ->
    mediator.data.set 'virtual-checkout', no
    utils.redirectTo controller: 'login', action: 'index'