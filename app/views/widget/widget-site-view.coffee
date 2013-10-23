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
    @delegate 'click', '#btn-login', @showLoginLayer
    @delegate 'click', '.close-modal', @closeModal
    @delegate 'click', 'i.close-icon', @closeModal
    @delegate 'click', '#registerLink', @viewRegister
    @delegate 'click', '#viewVideoLink', @viewVideo
    @delegate 'click', '#postCheckout', @postCheckout

    @delegate 'click', '#twitterShare', @twitterShare
    @delegate 'click', '#facebookShare', @facebookShare

    #@delegate 'shown', '#login-modal', @placeFacebookFrame
    @delegate 'shown', '#register-modal', @placeFacebookFrame


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

  updateCartCounter: (count)->
    console.log ["WidgetSiteView#updateCartCounter " + count]
    @$el.find(".cart-items-count").html(count)

  showLoginLayer: (e)->
    e.preventDefault()
    @publishEvent 'cleanModal'
    console.log "WidgetSiteView#showLoginLayer"
    @$("#login-modal").modal( 'show' ).css {
      width: '330px',
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%',
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )
    }


  viewRegister: (e)->
    @$('.modal').modal 'hide'
    console.log "WidgetSiteView#viewRegister"
    that = @
    @$("#register-modal").modal( 'show' ).css {
      width: '520px',
      'margin-left': -> -( that.$( this ).width() / 2 )
      top: '50%',
      'margin-top': -> -(  that.$( this ).height() / 2 )
    }

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

  closeModal: (event) ->
    event?.preventDefault()
    event?.stopPropagation()
    @$('.modal').modal 'hide'

  showConfirmation: () ->
    console.log "WidgetSiteView#showConfirmation"
    Backbone.$("#register-confirm-modal").modal( 'show' ).css {
      width: '625px',
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%',
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )
    }

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
    that = this
    @$el.find("#winbits-logout-link").on("click",  (e)->
      that.logout(e)
    )
    that = @
#    TODO: Ask why this does not work
    @$("#login-modal").on "shown", ->
      that.placeFacebookFrame()

    @$("#login-modal, #register-modal").on "hide", ->
      console.log "close"
      that.$("#winbits-iframe-holder").offset top: -1000

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

    Backbone.$.validator.addMethod 'validDate', ( (value, element) ->
      date = Date.parse(value)
      Object::toString.call(date) isnt "[object Date]" && !isNaN(date)
    ), "La fecha debe de ser válida"

    @$el.find('.wb-vertical-' + config.verticalId).addClass('current');
    $el = @$el
    setTimeout(() ->
      console.log 'DOING PLACEHOLDERS'
      $el.find('input, textarea').placeholder()
    , 500)

    @$el.find('#wbi-ajax-modal').modal({backdrop: 'static', keyboard: false, show: false})


  postCheckout: (e)->
    e.preventDefault()
    console.log "WidgetSiteView#postCheckout"
    util.showAjaxIndicator('Generando Orden...')
    Backbone.$.ajax config.apiUrl + "/orders/checkout.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      context: @
      data: JSON.stringify(verticalId: config.verticalId)
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.getCookie(config.apiTokenName)
      success: (data) ->
        console.log "Checkout Success!"
        resp = data.response
        warnings = resp.orderDetails? and (item for item in resp.orderDetails when item.warnings?)
        withWarnings = if warnings != null && warnings.length > 0  then true else false
        if resp.failedCartDetails? or withWarnings
          @publishEvent 'showResume', resp
        else
          @postToCheckoutApp resp

      error: (xhr) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)
#        alert error.meta.message

      complete: ->
        util.hideAjaxIndicator()

  placeFacebookFrame: (e) ->
    console.log "Facebook Frame disable!"

  updateBitsBalanceWithProfile: (profile) ->
    @updateBitsBalance profile.bitsBalance

  updateBitsBalance: (bitsBalance) ->
    @$el.find('.wb-user-bits-balance').text bitsBalance

  updateBitsBalanceWithCart: (cart) ->
    bitsBalance = mediator.profile.bitsBalance
    bitsTotal = cart.bitsTotal
    @updateBitsBalance bitsBalance - bitsTotal
    $ = window.$ or w$
    $('#' + config.winbitsDivId).trigger 'bitschanged', [{bitsBalance: bitsBalance, bitsTotal: bitsTotal}]

  postToCheckoutApp: (order) ->
    @publishEvent 'restoreCart'
    $chkForm = w$('<form id="chk-form" method="POST" style="display:none"></form>')
    $chkForm.attr("action", config.baseUrl + "/checkout.php")
    $chkForm.append w$('<input type="hidden" name="token"/>').val(util.getCookie(config.apiTokenName))
    $chkForm.append w$('<input type="hidden" name="order_data"/>').val(JSON.stringify(order))
    $chkForm.append w$('<input type="hidden" name="bits_balance"/>').val(mediator.profile.bitsBalance)
    $chkForm.append w$('<input type="hidden" name="vertical_id"/>').val(config.verticalId)

    @$el.append $chkForm
    $chkForm.submit()

  twitterShare: (e) ->
    e.preventDefault()
    that = @
    console.log "twitter update status"
    Backbone.$.ajax config.apiUrl + "/affiliation/twitterPublish/updateStatus.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(message: 'Yo ya me registré en Winbits (twitter test)')
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log "updateStatus.json Success!"

      error: (xhr, textStatus, errorThrown) ->
        console.log "updateStatus.json Error!"
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "updateStatus.json Completed!"

  facebookShare: (e) ->
    e.preventDefault()
    that = @
    console.log "facebook share"
    Backbone.$.ajax config.apiUrl + "/affiliation/facebookPublish/share.json",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(message: 'Yo ya me registré en Winbits (facebook test)')
      xhrFields:
        withCredentials: true

      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log "share.json Success!"

      error: (xhr, textStatus, errorThrown) ->
        console.log "share.json Error!"
        util.showAjaxError(xhr.responseText)

      complete: ->
        console.log "share.json Completed!"

  forgotPassword: (e) ->
    console.log "WidgetSiteView#viewForgotPassword"
    @$('.modal').modal 'hide'
    that = @
    @$("#forgot-password-modal").modal( 'show' ).css {
      width: '330px',
      'margin-left': -> -( that.$( this ).width() / 2 )
      top: '50%',
      'margin-top': -> -(  that.$( this ).height() / 2 )
      'max-height': '370px'
    }

  resetPassword: (e) ->
    console.log "WidgetSiteView#viewResetPassword"
    @$('.modal').modal 'hide'
    that = @
    @$("#wbi-reset-password-modal").modal( 'show' ).css {
      width: '330px',
      'margin-left': -> -( that.$( this ).width() / 2 )
      top: '50%',
      'margin-top': -> -(  that.$( this ).height() / 2 )
      'max-height': '370px'
    }

  proxyLoaded: (e) ->
    params = util.getUrlParams()
    console.log ['PROXY LOADED', params ]
    if params._wb_active is "true" and params._wb_register_confirm is "true"
      @publishEvent 'expressLogin', params._wb_api_token
