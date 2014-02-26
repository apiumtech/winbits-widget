View = require 'views/base/view'
template = require 'views/templates/widget/widget-site'
util = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
mediator = require 'chaplin/mediator'
token = require 'lib/token'

# Site view is a top-level view which is bound to body.
module.exports = class WidgetSiteView extends View
  container: '#winbits-widget'
  autoRender: yes
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
#  id: "widgetSiteView"
  template: template

  initialize: ->
    super
    @delegate 'click', '#btn-login', @loginBtnClick
    @delegate 'click', '.close-modal', @closeModal
    @delegate 'click', 'i.close-icon', @closeModal
    @delegate 'click', '#registerLink', @registerLinkClick
    @delegate 'click', '#viewVideoLink', @viewVideo
    @delegate 'click', '#postCheckout', @postCheckout

    @delegate 'click', '#twitterShare', @twitterShare
    @delegate 'click', '#facebookShare', @facebookShare
    @delegate 'hide', '#register-modal', @verifyNullFields

    @delegate 'shown', '#login-modal', @requestFocus
    @delegate 'hidden', '#login-modal', @resetForm
    @delegate 'shown', '#register-modal', @requestFocus
    @delegate 'hidden', '#register-modal', @resetForm
    @delegate 'shown', '#forgot-password-modal', @requestFocus
    @delegate 'hidden', '#forgot-password-modal', @resetForm
    @delegate 'click', '#wbi-close-switch-user', @switchUserLogout
    @delegate 'click', '.triggerMiCuenta', (e)-> util.toggleDropMenus(e, '.miCuentaDiv')
    @delegate 'click', '.triggerMiCarrito', (e)-> @toggleCart(e)
    @delegate 'click', '.miCuentaDiv .wrapper', (e) -> e.stopPropagation()

    @subscribeEvent 'showHeaderLogin', @showHeaderLogin
    @subscribeEvent 'showHeaderLogout', @showHeaderLogout
    @subscribeEvent 'resetComponents', @resetComponents
    @subscribeEvent 'updateCartCounter', @updateCartCounter
    @subscribeEvent 'showConfirmation', @showConfirmation
    @subscribeEvent 'showMessageConfirm', @showMessageConfirm
    @subscribeEvent 'showRegister', @viewRegister
    @subscribeEvent 'showLogin', @showLoginLayer
    @subscribeEvent 'applyLogin', @updateBitsBalanceWithProfile
    @subscribeEvent 'cartBitsUpdated', @updateBitsBalanceWithCart
    @subscribeEvent 'showForgotPassword', @forgotPassword
    @subscribeEvent 'cleanModal', @closeModal
    @subscribeEvent 'postToCheckoutApp', @postToCheckoutApp
    @subscribeEvent 'showResetPassword', @resetPassword
    @subscribeEvent 'proxyLoaded', @proxyLoaded
    @subscribeEvent 'doCheckout', @doCheckout
    @subscribeEvent 'setBitsBalance', @updateBitsBalance
    @subscribeEvent 'logout', @deleteSwitchUserInfo

  updateCartCounter: (count)->
    console.log ["WidgetSiteView#updateCartCounter " + count]
    @$el.find(".wb-cart-items-count").html(count)

  loginBtnClick: (e) ->
    e.preventDefault()
    mediator.flags.autoCheckout = false
    @showLoginLayer()

  showLoginLayer: ()->
    @publishEvent 'cleanModal'
    console.log "WidgetSiteView#showLoginLayer"
    @$("#login-modal").modal( 'show' ).css
      width: '330px'
      'margin-left': -> -( Winbits.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  Winbits.$( this ).height() / 2 )

  registerLinkClick: (e) ->
    e.preventDefault()
    mediator.flags.autoCheckout = false
    @viewRegister()

  viewRegister: ()->
    @$('.modal').modal 'hide'
    console.log "WidgetSiteView#viewRegister"
    that = @
    @$("#register-modal").modal( 'show' ).css
      width: '520px'
      'margin-left': -> -( that.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  that.$( this ).height() / 2 )

  viewVideo: (e)->
    e.preventDefault()
    console.log "WidgetSiteView#viewVideo"
    that = @
    @$("#view-video-modal").modal( 'show' ).css {
      width: '560px',
      'margin-left': -> -( that.$( this ).width() / 2 )
      top: '50%',
      'margin-top': -> -(  that.$( this ).height() / 2 )
    }

  closeModal: (e) ->
    if e?
      e.preventDefault()
      e.stopPropagation()
      @$(e.currentTarget).closest('.modal').modal 'hide'
    else
      @$('.modal').modal 'hide'

  showConfirmation: () ->
    console.log "WidgetSiteView#showConfirmation"
    Winbits.$("#register-confirm-modal").modal( 'show' ).css
      width: '625px'
      'margin-left': -> -( Winbits.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  Winbits.$( this ).height() / 2 )

  showMessageConfirm: (modalId) ->
    Winbits.$(modalId).modal( 'show' ).css {
      width: '625px',
      'margin-left': -> -( Winbits.$( this ).width() / 2 )
      top: '50%',
      'margin-top': -> -(  Winbits.$( this ).height() / 2 )
    }

  showHeaderLogin: () ->
    console.log "WidgetSiteView#showHeaderLogin"
    @checkSwitchUser()
    @$el.find("#headerLogin").show()
    @$el.find("#headerNotLogin").hide()

  checkSwitchUser: ()->
    if mediator.global.profile.switchUser?
      @$el.find('#wbi-div-switch-user').show()
      @$el.find('#wbi-em-switch-user').append Winbits.$("<span>").attr('id', 'clientUserEmail').text(mediator.global.profile.switchUser)

  showHeaderLogout: () ->
    console.log "WidgetSiteView#showHeaderLogout"
    @$el.find("#headerLogin").hide()
    @$el.find("#headerNotLogin").show()

  resetComponents: () ->
    console.log "WidgetSiteView#resetComponents"
    util.resetComponents()

  logout: (e) ->
    e.preventDefault()
    e.stopPropagation()
    console.log "logout"
    @publishEvent "initLogout"

  attach: ->
    super
    console.log "WidgetSiteView#attach"
    that = @
    @$el.find("#winbits-logout-link").on "click",  (e)->
      that.logout(e)

#    vendor.dropMenu
#      obj: ".miCuentaDiv"
#      clase: ".dropMenu"
#      trigger: ".triggerMiCuenta, .miCuenta .link"
#      other: ".miCarritoDiv"

    vendor.openFolder
      obj: ".knowMoreMin"
      trigger: ".knowMoreMin .openClose"
      objetivo: ".knowMoreMax"

    vendor.openFolder
      obj: ".knowMoreMax"
      trigger: ".knowMoreMax .openClose"
      objetivo: ".knowMoreMin"

    vendor.stickyFooter ".widgetWinbitsFooter"

    Winbits.$.validator.addMethod 'validDate', (value) ->
      if value
        moment(value, 'YYYY-MM-DD').isValid()
      else
        true
    , "La fecha debe de ser válida"

    @$el.find('.wb-vertical-' + config.verticalId).addClass('current');
    @$el.find('#wbi-ajax-modal').modal({backdrop: 'static', keyboard: false, show: false})

  postCheckout: (e)->
    e.preventDefault()
    @doCheckout()

  doCheckout: (delay) ->
    $ = Winbits.$
    @timeDelay = 0
    if delay
       @timeDelay = 1500
    if $('.wb-cart-detail-list').children().length > 0
      util.showAjaxIndicator('Generando tu Orden...')
      that = @
      _.delay util.ajaxRequest, @timeDelay,  config.apiUrl + "/orders/checkout.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(verticalId: config.verticalId)
        headers:
          "Accept-Language": "es",
          "WB-Api-Token": util.retrieveKey(config.apiTokenName)

        success: (data) ->
          console.log "Checkout Success!"
          resp = data.response
          warnings = resp.orderDetails? and (item for item in resp.orderDetails when item.warnings?)
          withWarnings = if warnings != null && warnings.length > 0  then true else false
          if resp.failedCartDetails? or withWarnings
            util.hideAjaxIndicator()
            that.publishEvent 'showResume', resp
          else
            that.postToCheckoutApp resp
        error: (xhr) ->
          console.log xhr
          error = JSON.parse(xhr.responseText)
          util.hideAjaxIndicator()

    else
      util.showError('Agrega algo a tu carrito para que lo puedas comprar')

  updateBitsBalanceWithProfile: (profile) ->
    console.log ['Updating bits balance with profile', profile.bitsBalance]
    @updateBitsBalance profile.bitsBalance

  updateBitsBalance: (bitsBalance) ->
    console.log ['Updating bits balance', bitsBalance]
    @$el.find('.wb-user-bits-balance').text(bitsBalance or 0)

  updateBitsBalanceWithCart: (cart) ->
    bitsBalance = mediator.profile.bitsBalance
    console.log ['Updating bits balance with cart', bitsBalance]
    if bitsBalance?
      bitsTotal = cart.bitsTotal or 0
      @updateBitsBalance(bitsBalance - bitsTotal)
      $ = window.$ or Winbits.$
      $('#' + config.winbitsDivId).trigger 'bitschanged', [{bitsBalance: bitsBalance, bitsTotal: bitsTotal}]

  postToCheckoutApp: (order) ->
    @publishEvent 'restoreCart'
    $chkForm = Winbits.$('<form id="chk-form" method="POST" style="display:none"></form>')
    $chkForm.attr("action", config.baseUrl + "/checkout.php")
    $chkForm.append Winbits.$('<input type="hidden" name="token"/>').val(util.retrieveKey(config.apiTokenName))
    $chkForm.append Winbits.$('<input type="hidden" name="order_id"/>').val(order.id)
    $chkForm.append Winbits.$('<input type="hidden" name="bits_balance"/>').val(mediator.profile.bitsBalance)
    $chkForm.append Winbits.$('<input type="hidden" name="vertical_id"/>').val(config.verticalId)
    $chkForm.append Winbits.$('<input type="hidden" name="vertical_url"/>').val(order.vertical.url)
    $chkForm.append Winbits.$('<input type="hidden" name="timestamp"/>').val(new Date().getTime())

    @$el.append $chkForm
    $chkForm.submit()

  twitterShare: (e) ->
    e.preventDefault()
    console.log "twitter update status"
    util.ajaxRequest config.apiUrl + "/users/twitterPublish/updateStatus.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(message: 'Yo ya me registré en Winbits (twitter test)')
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        console.log "updateStatus.json Success!"

      error: (xhr, textStatus, errorThrown) ->
        console.log "updateStatus.json Error!"
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "updateStatus.json Completed!"

  facebookShare: (e) ->
    e.preventDefault()
    console.log "facebook share"
    util.ajaxRequest( config.apiUrl + "/users/facebookPublish/share.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(message: 'Yo ya me registré en Winbits (facebook test)')
      xhrFields:
        withCredentials: true
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.retrieveKey(config.apiTokenName)

      success: (data) ->
        console.log "share.json Success!"
      error: (xhr) ->
        console.log "share.json Error!"
        util.showAjaxError(xhr.responseText)
      complete: ->
        console.log "share.json Completed!"
    )
  forgotPassword: () ->
    console.log "WidgetSiteView#viewForgotPassword"
    @$('.modal').modal 'hide'
    that = @
    @$("#forgot-password-modal").modal( 'show' ).css
      width: '330px'
      'margin-left': -> -( that.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  that.$( this ).height() / 2 )
      'max-height': '370px'
    console.log ['AFTER FORGOT']

  resetPassword: (e) ->
    console.log "WidgetSiteView#viewResetPassword"
    @$('.modal').modal 'hide'
    that = @
    @$("#wbi-reset-password-modal").modal( 'show' ).css
      width: '330px'
      'margin-left': -> -( that.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  that.$( this ).height() / 2 )
      'max-height': '370px'

  proxyLoaded: () ->
    console.log('Proxy Loaded Handler...')
    that = @
    hashHandlers =
      '#complete-register': (response) ->
        if response.profile?
          that.publishEvent "showCompletaRegister", response
          that.publishEvent 'setRegisterFb', response.profile
      '#switch-user': Winbits.$.noop
    token.requestTokens(Winbits.$) unless @processHashHandlers(hashHandlers)

  processHashHandlers: (hashHandlers) ->
    hashParts = location.hash.split('-')
    Winbits.$('a#wbi-dummy-link').get(0).click()
    apiToken = hashParts.pop().substring(0, 64)
    callback = _.find hashHandlers, (value, key) ->
      key is hashParts.join('-')
    if callback
      @publishEvent 'expressLogin', apiToken, callback
    callback?

  requestFocus: (e) ->
    $form = Winbits.$(e.currentTarget).find('form')
    util.focusForm($form)

  resetForm: (e) ->
    $form = Winbits.$(e.currentTarget).find('form')
    util.resetForm($form)

  verifyNullFields: (e) ->
    $registerModal = Winbits.$(e.currentTarget)
    $completeRegisterLayer = $registerModal.find('#complete-register-layer')
    if $completeRegisterLayer.is(':visible')
      $registerModal.find("#complete-register-layer").hide()
      $registerModal.find("#winbits-register-form").show()
      $form =  @$el.find("#complete-register-form")
      formData = util.serializeForm($form)
      bandera = false
      Winbits.$.each(formData, (i, value) ->
        if not value
          bandera = true
          return false
      )
      if bandera == true
        @publishEvent ('completeProfileRemainder')

  deleteSwitchUserInfo: ->
    @$el.find('#wbi-switched-user').delete()

  switchUserLogout: (e)->
    @logout(e)
    @$el.find('#wbi-div-switch-user').hide()

  toggleCart: (e) ->
    e.stopPropagation()
    if Winbits.$(e.currentTarget).find(".wb-cart-items-count").text().trim() is '0'
       return
    util.toggleDropMenus(e, '.miCarritoDiv')
