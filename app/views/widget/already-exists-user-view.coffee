View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class AlreadyExistsUserView extends View
  autoRender: yes
  container: '#wbi-already-exist-user-modal'
  template: require 'views/templates/widget/already-exist-user'

  initialize: ->
    super
    @delegate 'click', '#wbi-already-exist-user-link', @onResendResetPasswordLinkClick
    @subscribeEvent 'alreadyexistuser', @onUserNotConfirmed

  attach: ->
    super
    @$el.find('.winbits-register-form').modal(show: false)


  onUserNotConfirmed: ->
    console.log("AFTER EVENT!!!!")
    w$('.modal').modal('hide')
    @$el.find('.modal').modal('show').css(
      width: '625px',
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )
    ).closest('.wb-modal-holder').show()
    @$el.find('#wbi-already-exist-user-link')


  onRensendConfirmationLinkClick: (e) ->
    e.preventDefault()
    @resendConfirmationMail()

  onResendResetPasswordLinkClick: () ->

  resendConfirmationMail: ->
    console.log("Send email password reset")