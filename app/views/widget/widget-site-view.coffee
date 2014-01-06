View = require 'views/base/view'
template = require 'views/templates/widget/widget-site'
util = require 'lib/util'
vendor = require 'lib/vendor'
config = require 'config'
ProxyInit = require 'lib/proxyInit'
mediator = require 'chaplin/mediator'

# Site view is a top-level view which is bound to body.
module.exports = class WidgetSiteView extends View
  container: '#winbits-widget'
  autoRender: yes
  #regions:
  #'#header-container': 'header'
  #'#page-container': 'main'
  id: "widgetSiteView"
  template: template
  proxyInit: null

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
    @initMomentTimeZone()

  initMomentTimeZone: ->
    moment.tz.add
      zones:
        "America/Mexico_City": [
          "-6:36:36 - LMT 1922_0_1_0_23_24 -6:36:36",
          "-7 - MST 1927_5_10_23 -7",
          "-6 - CST 1930_10_15 -6",
          "-7 - MST 1931_4_1_23 -7",
          "-6 - CST 1931_9 -6",
          "-7 - MST 1932_3_1 -7",
          "-6 Mexico C%sT 2001_8_30_02 -5",
          "-6 - CST 2002_1_20 -6",
          "-6 Mexico C%sT"
        ]
      rules:
        Mexico: [
          "1939 1939 1 5 7 0 0 1 D",
          "1939 1939 5 25 7 0 0 0 S",
          "1940 1940 11 9 7 0 0 1 D",
          "1941 1941 3 1 7 0 0 0 S",
          "1943 1943 11 16 7 0 0 1 W",
          "1944 1944 4 1 7 0 0 0 S",
          "1950 1950 1 12 7 0 0 1 D",
          "1950 1950 6 30 7 0 0 0 S",
          "1996 2000 3 1 0 2 0 1 D",
          "1996 2000 9 0 8 2 0 0 S",
          "2001 2001 4 1 0 2 0 1 D",
          "2001 2001 8 0 8 2 0 0 S",
          "2002 9999 3 1 0 2 0 1 D",
          "2002 9999 9 0 8 2 0 0 S"
        ]
      links: {}
    moment().tz("America/Mexico_City").format();

  updateCartCounter: (count)->
    console.log ["WidgetSiteView#updateCartCounter " + count]
    @$el.find(".cart-items-count").html(count)

  loginBtnClick: (e) ->
    e.preventDefault()
    mediator.flags.autoCheckout = false
    @showLoginLayer()

  showLoginLayer: ()->
    @publishEvent 'cleanModal'
    console.log "WidgetSiteView#showLoginLayer"
    @$("#login-modal").modal( 'show' ).css
      width: '330px'
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )

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
    Backbone.$("#register-confirm-modal").modal( 'show' ).css
      width: '625px'
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%'
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )

  showMessageConfirm: (modalId) ->
    Backbone.$(modalId).modal( 'show' ).css {
      width: '625px',
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%',
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )
    }

  showHeaderLogin: () ->
    console.log "WidgetSiteView#showHeaderLogin"
    @$el.find("#headerLogin").show()
    @$el.find("#headerNotLogin").hide()

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
    @proxyInit = new ProxyInit()
    that = @
    @$el.find("#winbits-logout-link").on "click",  (e)->
      that.logout(e)

    vendor.dropMenu
      obj: ".miCuentaDiv"
      clase: ".dropMenu"
      trigger: ".triggerMiCuenta, .miCuenta .link"
      other: ".miCarritoDiv"

    vendor.openFolder
      obj: ".knowMoreMin"
      trigger: ".knowMoreMin .openClose"
      objetivo: ".knowMoreMax"

    vendor.openFolder
      obj: ".knowMoreMax"
      trigger: ".knowMoreMax .openClose"
      objetivo: ".knowMoreMin"

    vendor.stickyFooter ".widgetWinbitsFooter"

    Backbone.$.validator.addMethod 'validDate', (value) ->
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

  doCheckout: () ->
    $ = Backbone.$
    if $('.wb-cart-detail-list').children().length > 0
      util.showAjaxIndicator('Generando tu Orden...')
      that = @
      util.ajaxRequest( config.apiUrl + "/orders/checkout.json",
        type: "POST"
        contentType: "application/json"
        dataType: "json"
#        context: @
        data: JSON.stringify(verticalId: config.verticalId)
        headers:
          "Accept-Language": "es",
          "WB-Api-Token": util.getCookie(config.apiTokenName)
      )
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
  #        alert error.meta.message

        complete: ->
#          util.hideAjaxIndicator()
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
      $ = window.$ or w$
      $('#' + config.winbitsDivId).trigger 'bitschanged', [{bitsBalance: bitsBalance, bitsTotal: bitsTotal}]

  postToCheckoutApp: (order) ->
    @publishEvent 'restoreCart'
    $chkForm = w$('<form id="chk-form" method="POST" style="display:none"></form>')
    $chkForm.attr("action", config.baseUrl + "/checkout.php")
    $chkForm.append w$('<input type="hidden" name="token"/>').val(util.getCookie(config.apiTokenName))
    $chkForm.append w$('<input type="hidden" name="order_id"/>').val(order.id)
    $chkForm.append w$('<input type="hidden" name="bits_balance"/>').val(mediator.profile.bitsBalance)
    $chkForm.append w$('<input type="hidden" name="vertical_id"/>').val(config.verticalId)
    $chkForm.append w$('<input type="hidden" name="vertical_url"/>').val(order.vertical.url)
    $chkForm.append w$('<input type="hidden" name="timestamp"/>').val(new Date().getTime())

    @$el.append $chkForm
    $chkForm.submit()

  twitterShare: (e) ->
    e.preventDefault()
    console.log "twitter update status"
    util.ajaxRequest( config.apiUrl + "/affiliation/twitterPublish/updateStatus.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(message: 'Yo ya me registré en Winbits (twitter test)')
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)
    )
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
    util.ajaxRequest( config.apiUrl + "/affiliation/facebookPublish/share.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(message: 'Yo ya me registré en Winbits (facebook test)')
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)
    )
      success: (data) ->
        console.log "share.json Success!"

      error: (xhr) ->
        console.log "share.json Error!"
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "share.json Completed!"

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
    hash = location.hash
    hashParts = hash.split('-')
    if hashParts[0] is '#complete' and hashParts[1] is 'register'
      apiToken = hashParts[2].substring(0, 64)
      @publishEvent 'expressLogin', apiToken

  requestFocus: (e) ->
    $form = Backbone.$(e.currentTarget).find('form')
    util.focusForm($form)

  resetForm: (e) ->
    $form = Backbone.$(e.currentTarget).find('form')
    util.resetForm($form)

  verifyNullFields: (e) ->
    $registerModal = w$(e.currentTarget)
    $completeRegisterLayer = $registerModal.find('#complete-register-layer')
    if $completeRegisterLayer.is(':visible')
      $registerModal.find("#complete-register-layer").hide()
      $registerModal.find("#winbits-register-form").show()
      $form =  @$el.find("#complete-register-form")
      formData = util.serializeForm($form)
      bandera = false
      w$.each(formData, (i, value) ->
        if not value
          bandera = true
          return false
      )
      if bandera == true
        @publishEvent ('completeProfileRemainder')
