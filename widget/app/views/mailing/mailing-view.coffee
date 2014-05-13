'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env
_ = Winbits._

module.exports = class MailingView extends View
  container: '#wb-mailing'
  template: require './templates/mailing'

  initialize: () ->
    super
    @delegate 'click', '#wbi-mailing-btn', @doRequestSuscriptionsUpdate

  attach: ->
    super
    @$('#wbi-mailing-form').customCheckbox()
    @$('#wbi-how-to-received').customRadio()
    @$('#wbi-how-often-to-received').customRadio()
    @$('.checkboxLabel').css('width', '150')
    @$('#wbi-mailing-btn').css('left', '0')

  doRequestSuscriptionsUpdate: ->
    subscriptions = _.map( @$('.wbc-subscription-check'),(check)-> {id: $(check).val(), active: $(check).prop(':checked')})
    $form =  @$("#wbi-mailing-form")
    data = utils.serializeForm($form,subscriptions: subscriptions)
    console.log ["Serialize form", data]
    #var a = {subscriptions: Winbits._.map(Winbits.$('.wbc-subscription-check'), function(check) { return {id: Winbits.$(check).val(), active: Winbits.$(check).prop('checked')}; }) }

