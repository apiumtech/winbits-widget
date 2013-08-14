View = require 'views/base/view'
template = require 'views/templates/widget/widget-site'
util = require 'lib/util'
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
    @subscribeEvent 'showRegister', @viewRegister
    @subscribeEvent 'applyLogin', @updateBitsBalanceWithProfile
    @subscribeEvent 'cartBitsUpdated', @updateBitsBalanceWithCart

  updateCartCounter: (count)->
    console.log ["WidgetSiteView#updateCartCounter " + count]
    @$el.find(".cart-items-count").html(count)

  showLoginLayer: (e)->
    e.preventDefault()
    console.log "WidgetSiteView#showLoginLayer"
    #console.log $("#login-layer")
    maxHeight = Backbone.$(window).height() - 200
    @$("#login-modal .modal-body").css("max-height", maxHeight)
    @$("#login-modal").modal( 'show' ).css {
      'background-color': 'transparent',
      float: 'left',
      width: '330px',
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%',
      'max-height': maxHeight,
      'margin-top': -> -(  Backbone.$( this ).height() / 2 )
    }

    that=@


  viewRegister: (e)->
    #e.preventDefault()
    console.log "WidgetSiteView#viewRegister"
    #console.log $("#login-layer")
    maxHeight = @$(window).height() - 200
    that = @
    @$("#register-modal .modal-body").css("max-height", maxHeight)
    @$("#register-modal").modal( 'show' ).css {
      'background-color': 'transparent',
      float: 'left',
      width: '520px',
      'margin-left': -> -( that.$( this ).width() / 2 )
      top: '50%',
      'max-height': maxHeight,
      'margin-top': -> -(  that.$( this ).height() / 2 )
    }

  viewVideo: (e)->
    e.preventDefault()
    console.log "WidgetSiteView#viewVideo"
    #console.log $("#login-layer")
    maxHeight = @$(window).height() - 200
    that = @
    @$("#view-video-modal .modal-body").css("max-height", maxHeight)
    @$("#view-video-modal").modal( 'show' ).css {
      'background-color': 'transparent',
      float: 'left',
      width: '560px',
      'margin-left': -> -( that.$( this ).width() / 2 )
      top: '50%',
      'max-height': maxHeight,
      'margin-top': -> -(  that.$( this ).height() / 2 )
    }

  closeModal: (event) ->
    event?.preventDefault()
    event?.stopPropagation()
    @$('.modal').modal 'hide'

  showConfirmation: () ->
    console.log "WidgetSiteView#showConfirmation"
    #console.log $("#login-layer")
    maxHeight = Backbone.$(window).height() - 200
    Backbone.$("#register-confirm-modal .modal-body").css("max-height", maxHeight)
    Backbone.$("#register-confirm-modal").modal( 'show' ).css {
      'background-color': 'transparent',
      float: 'left',
      width: '625px',
      'margin-left': -> -( Backbone.$( this ).width() / 2 )
      top: '50%',
      'max-height': maxHeight,
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

    util.dropMenu
      obj: ".miCuentaDiv"
      clase: ".dropMenu"
      trigger: ".triggerMiCuenta"
      other: ".miCarritoDiv"

    util.dropMenu
      obj: ".miCarritoDiv"
      clase: ".dropMenu"
      trigger: ".shopCarMin"
      other: ".miCuentaDiv"


    util.openFolder
      obj: ".knowMoreMin"
      trigger: ".knowMoreMin .openClose"
      objetivo: ".knowMoreMax"

    util.openFolder
      obj: ".knowMoreMax"
      trigger: ".knowMoreMax .openClose"
      objetivo: ".knowMoreMin"

    @$el.find('.wb-vertical-' + config.verticalId).addClass('current');

  postCheckout: (e)->
    e.preventDefault()
    console.log "WidgetSiteView#postCheckout"
    Backbone.$.ajax config.apiUrl + "/orders/checkout",
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      context: @
      headers:
        "Accept-Language": "es",
        "WB-Api-Token": util.getCookie(config.apiTokenName)
      success: (data) ->
        console.log "Checkout Success!"
        console.log ["data", data]
        @postToCheckoutApp data.response

      error: (xhr, textStatus, errorThrown) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)

      complete: ->
        console.log "Request Completed!"

  placeFacebookFrame: (e) ->
    console.log "Facebook Frame disable!"

  updateBitsBalanceWithProfile: (profile) ->
    @updateBitsBalance profile.bitsBalance

  updateBitsBalance: (bitsBalance) ->
    @$el.find('.wb-user-bits-balance').text bitsBalance

  updateBitsBalanceWithCart: (cart) ->
    @updateBitsBalance mediator.profile.bitsBalance - cart.bitsTotal

  postToCheckoutApp: (order) ->
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
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

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
        error = JSON.parse(xhr.responseText)
        alert error.meta.message

      complete: ->
        console.log "share.json Completed!"
