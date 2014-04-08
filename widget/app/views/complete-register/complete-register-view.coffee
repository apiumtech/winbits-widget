View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$
env = Winbits.env

module.exports = class CompleteRegisterView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-complete-register-modal'
  template: require './templates/complete-register'

  initialize: ->
    console.log 'initialize-complete register'
    super
#    @listenTo @model, 'change', @render

  attach: ->
    super
    @showAsModal()
    @$('.divGender').customRadio()

  showAsModal: ->
    $('<a>').wbfancybox(href: '#wbi-complete-register-modal', onClosed: -> utils.redirectToLoggedInHome()).click()
