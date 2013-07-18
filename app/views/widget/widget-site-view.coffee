View = require 'views/base/view'
template = require 'views/templates/widget/widget-site'
util = require 'lib/util'
config = require 'config'
ProxyInit = require 'lib/proxyInit'

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
    #@delegate 'shown', '#login-modal', @placeFacebookFrame
    @delegate 'shown', '#register-modal', @placeFacebookFrame
    @subscribeEvent 'showHeaderLogin', @showHeaderLogin
    @subscribeEvent 'showHeaderLogout', @showHeaderLogout
    @subscribeEvent 'resetComponents', @resetComponents
    @subscribeEvent 'updateCartCounter', @updateCartCounter
    @subscribeEvent 'showConfirmation', @showConfirmation
    @subscribeEvent 'showRegister', @viewRegister

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
        $chkForm = @$el.find("#chk-form")
        console.log $chkForm
        $token = $chkForm.find("#token")
        $order_data = $chkForm.find("#order_data")
        $token.val(util.getCookie(config.apiTokenName))
        $order_data.val(data)
        $chkForm.attr("action", config.baseUrl + "/checkout.php")
        $chkForm.submit()
        $token.val('')
        $order_data.val('')
      error: (xhr, textStatus, errorThrown) ->
        console.log xhr
        error = JSON.parse(xhr.responseText)

      complete: ->
        console.log "Request Completed!"

  placeFacebookFrame: (e) ->
    $fbHolder = @$el.find(".facebook-btn-holder:visible")
    $fbLink = $fbHolder.find(".btnFacebook")
    $fbIFrameHolder = @$el.find("#winbits-iframe-holder")
    offset = $fbHolder.delay(250).offset()
    setTimeout () ->
      offset.top = $fbLink.offset().top
      $fbIFrameHolder.offset(offset).height(35).width($fbHolder.width()).css "z-index", 10000
    , 750
