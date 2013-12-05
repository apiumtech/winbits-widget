View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class ResendConfirmationView extends View
  autoRender: yes
  container: '#wbi-resend-confirmation-modal'
  template: require 'views/templates/widget/resend-confirmation'

  initialize: ->
    super
    @delegate 'click', '#wbi-resend-confirmation-link', @onRensendConfirmationLinkClick

    @subscribeEvent 'userNotConfirmed', @onUserNotConfirmed

  attach: ->
    super
    @$el.find('.modal').modal(show: false)


  onUserNotConfirmed: (resendConfirmUrl) ->
    w$('.modal').modal('hide')
    @$el.find('.modal').modal('show').css(
      width: '625px',
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )
    ).closest('.wb-modal-holder').show()
    @$el.find('#wbi-resend-confirmation-link').data('resend-confirm-url', resendConfirmUrl)

  onRensendConfirmationLinkClick: (e) ->
    e.preventDefault()
    @resendConfirmationMail()

  resendConfirmationMail: ->
    $resendConfirmLink = @$el.find('#wbi-resend-confirmation-link')
    resendConfirmUrl = $resendConfirmLink.data('resend-confirm-url')
    $resendConfirmLink.prop('disabled', true)
    Backbone.$.ajax config.apiUrl + resendConfirmUrl.substring(resendConfirmUrl.indexOf('/affiliation')),
      dataType: "json"
      context: {view: @, $submitButton: $resendConfirmLink}
      headers:
        "Accept-Language": "es"
      success: () ->
        @view.$el.find('.modal').modal('hide')
        @view.publishEvent 'showConfirmation'

      complete: ->
        @$submitButton.prop('disabled', false)
