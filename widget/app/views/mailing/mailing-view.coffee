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
    @listenTo @model,  'change', -> @render()
    @delegate 'click', '#wbi-mailing-btn', @doRequestSuscriptionsUpdate
    @delegate 'click', '#wbi-mailing-thanks-btn-close', @doCloseThanksDiv

  attach: ->
    super
    @$('#wbi-mailing-form').validate
      errorPlacement: ($error, $element) ->
        if $element.attr("verticals")
          $error.appendTo $element.parent()
      rules:
        verticals:
          required: true

    @$('#wbi-mailing-form').customCheckbox().mailingMenuCheckboxs()
    @$('#wbi-how-to-received').customRadio()
    @$('#wbi-how-often-to-received').customRadio()
    @$('.checkboxLabel').css('width', '150')
    @$('#wbi-mailing-btn').css('left', '0')

  doRequestSuscriptionsUpdate: ->
    $form =@$('#wbi-mailing-form')
    if $form.valid()
      message = "Tus cambios han sido guardados exitosamente"
    else
      message = "Tus cambios han sido guardados exitosamente. Te invitamos a no perderte de nuestras ofertas con nuestro newsletter."

    @doSaveSubscriptionsSelected($form, message)

  doSaveSubscriptionsSelected:($form, message)->
    subscriptions = _.map( @$('.wbc-subscription-check'),
    (check)->
      $chk =  $(check)
      return {id: $chk.val(), active: $chk.prop('checked')}
    )
    $form =  @$("#wbi-mailing-form")
    data = utils.serializeForm($form,subscriptions: subscriptions)
    utils.showAjaxLoading()
    @model.requestUpdateSubscriptions(data, context: @)
    .done(-> @successSubscriptionsUpdate(message))
    .fail(@errorSubscriptionsUpdate)
    .always(@hideAjaxLoading)


  successSubscriptionsUpdate:(message) ->
    options = value: "Aceptar", title:'Cambios Guardados', icon:'iconFont-candado', onClosed: utils.redirectTo controller: 'home', action: 'index'
    utils.showMessageModal(message, options)

  hideAjaxLoading: ()->
    utils.hideAjaxLoading()

  errorSubscriptionsUpdate: () ->
    message = "Hubo un error al intentar actualizar las subscripciones, intentalo mas tarde"
    options = value: "Continuar", title:'Error al actualizar', icon:'iconFont-close', onClosed: utils.redirectTo controller: 'home', action: 'index'
    utils.showMessageModal(message, options)

  doCloseThanksDiv: ->
    @$('#wbi-mailing-thanks-div').slideUp()