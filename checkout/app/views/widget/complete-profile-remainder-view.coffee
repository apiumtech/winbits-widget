View = require 'views/base/view'
config = require 'config'
util = require 'lib/util'
token = require 'lib/token'
mediator = require 'chaplin/mediator'
vendor = require 'lib/vendor'

module.exports = class CompleteProfileRemainderView extends View
  autoRender: yes
  container: '#wbi-modals-holder'
  template: require 'views/templates/widget/complete-profile-remainder'

  initialize: ->
    super
    @delegate 'click', '#wbi-complete-profile-remainder', @onOpenProfileToEdit
    @subscribeEvent 'completeProfileRemainder', @onCompleteProfileRemainder

  attach: ->
    super
    console.log ['MODAL', @$el]
    @$el.find('.modal').modal(show: false)

  onCompleteProfileRemainder:->

      @$el.find('.modal').modal('show').css(
        width: '625px',
        'margin-left': -> -( Winbits.$( this ).width() / 2 )
        top: '50%'
        'margin-top': -> -(  Winbits.$( this ).height() / 2 )
      ).closest('.wb-modal-holder').show()

  onOpenProfileToEdit:->
    Winbits.$('.spanDropMenu').click()
    Winbits.$('#editBtnProfile').click()

