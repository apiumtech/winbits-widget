View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class ModalRegisterView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-register-modal'
  template: require './templates/recover-password'

  initialize: ->
    super

  attach: ->
    super
    @showAsModal()
    @$('#recuperaPsw').validate
      rules:
        email:
          required: true
          email: true

  showAsModal: ->
    $('<a>').wbfancybox(href: '#recuperaPsw', onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()

