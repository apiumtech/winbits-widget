View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class ResendConfirmationView extends View
  autoRender: yes
  container: '#wbi-modals-holder'
  template: require 'views/templates/widget/resend-confirmation'

  initialize: ->
    super
    @delegate 'click', '#wbi-resend-confirmation-link', @onRensendConfirmationLinkClick

    @subscribeEvent 'userNotConfirmed', @onUserNotConfirmed
    @subscribeEvent 'alreadyexistusernotconfirmed', @onUserNotConfirmed


  attach: ->
    super
    @$el.find('.modal').modal(show: false)


  onUserNotConfirmed: (resendConfirmUrl) ->
    w$('.modal').modal('hide')
    @$el.find('.modal').modal('show').css(
      width: '625px',
      'margin-left': -> -( Winbits.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  Winbits.$( this ).height() / 2 )
    ).closest('.wb-modal-holder').show()
    @$el.find('#wbi-resend-confirmation-link').data('resend-confirm-url', resendConfirmUrl)

  onRensendConfirmationLinkClick: (e) ->
    e.preventDefault()
    @resendConfirmationMail()

  resendConfirmationMail: ->
    $resendConfirmLink = @$el.find('#wbi-resend-confirmation-link')
    resendConfirmUrl = $resendConfirmLink.data('resend-confirm-url')
    $resendConfirmLink.prop('disabled', true)
    encodeComponent = encodeURI(resendConfirmUrl.substring(resendConfirmUrl.indexOf('/affiliation')))
    that = @
    util.ajaxRequest(config.apiUrl +  encodeComponent,
      dataType: "json"
#      context: {view: @, $submitButton: $resendConfirmLink}
      headers:
        "Accept-Language": "es"
      success: () ->
        that.$el.find('.modal').modal('hide').closest('.wb-modal-holder').hide()
        that.publishEvent 'showConfirmation'
      complete: ->
        $resendConfirmLink.prop('disabled', false)
    )
