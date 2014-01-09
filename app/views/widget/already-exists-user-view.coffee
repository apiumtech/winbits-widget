View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class AlreadyExistsUserView extends View
  autoRender: yes
  container: '#wbi-modals-holder'
  template: require 'views/templates/widget/already-exist-user'

  initialize: ->
    super
    @delegate 'click', '#wbi-already-exist-user-link', @onAlreadyExistUserLinkClick
    @subscribeEvent 'alreadyexistuser', @onUserNotConfirmed

  attach: ->
    super
    console.log ['MODAL', @$el]
    @$el.find('.modal').modal(show: false)

  onUserNotConfirmed: ->
    w$('.modal').modal('hide')
    @$el.find('.modal').modal('show').css(
      width: '625px',
      'margin-left': -> -( Winbits.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  Winbits.$( this ).height() / 2 )
    ).closest('.wb-modal-holder').show()

  onAlreadyExistUserLinkClick: (e) ->
    e.preventDefault()
    @$el.closest('.wb-modal-holder').hide()
    @publishEvent 'showForgotPassword'