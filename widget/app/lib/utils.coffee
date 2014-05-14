# Application-specific utilities
# ------------------------------

# Delegate to Chaplin’s utils module.
utils = Winbits.Chaplin.utils.beget Chaplin.utils
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
env = Winbits.env
rpc = env.get('rpc')

DEFAULT_API_ERROR_MESSAGE = 'El servidor no está disponible, por favor inténtalo más tarde.'

# _(utils).extend
#  someMethod: ->
_(utils).extend
  redirectToLoggedInHome: ->
    @redirectTo controller: 'logged-in', action: 'index'

  redirectToNotLoggedInHome: ->
    @redirectTo 'not-logged-in#index'

  getUrlParams : ->
    vars = []
    hash = `undefined`
    hashes = window.location.href.slice(window.location.href.indexOf("?") + 1).split("&")
    i = 0

    while i < hashes.length
      hash = hashes[i].split("=")
      vars.push hash[0]
      vars[hash[0]] = hash[1]
      i++
    vars

  redirectToVertical : (url)->
    window.location.href = url

  validateForm : (form) ->
    $form = $(form)
    $form.find(".errors").html ""
    $form.valid()

  justResetForm: (form) ->
    $form = $(form)
    $form.validate().resetForm()
    $form.get(0).reset()
    $form.find(".errors").html ""

  resetForm: (form) ->
    $form = $(form)
    @justResetForm($form)
    $form.valid()

  focusForm:  (form) ->
    $form = $(form)
    if not @isCrapBrowser()
      $form.find('input:visible:not([disabled]), textarea:visible:not([disabled])').first().focus()

  alertErrors : ($) ->
    params = util.getUrlParams()
    alert params._wb_error  if params._wb_error

  serializeForm : ($form, context) ->
    formData = context or {}
    $.each $form.serializeArray(), (i, f) ->
      formData[f.name] = f.value
    formData


  serializeProfileForm: ($form) ->
    formData = {birthdate : @getBirthdate($form)}
    formData = @serializeForm($form, formData)
    formData.gender = @getGender($form)
    formData

  getBirthdate: ($form) ->
   birthdate = (@getYear($form) + '-' + @getMonth($form) + '-' + @getDay($form))
   if birthdate.length != 10
     birthdate = null
   birthdate

  getDay: ($form) ->
    @getDateValue($form, ".wbc-day") or ''

  getMonth: ($form) ->
    @getDateValue($form, ".wbc-month") or ''

  getYear: ($form) ->
    year = @getDateValue($form, ".wbc-year") or ''
    if year.length
      currentYear = parseInt(moment().format('YYYY').slice(-2))
      year =  (if year > currentYear then "19" else "20") + year
    year


  resetComponents  : ()->
    $('.reseteable').each (i, reseteable) ->
      $reseteable = $(reseteable)
      resetVal = $reseteable.data('reset-val')
      if resetVal
        $reseteable.val resetVal
      else
        resetText = $reseteable.data('reset-text')
        if resetText
          $reseteable.text resetText
        else
          resetFn = if $reseteable.data('reset-unload') then $reseteable.html else $reseteable.val
          resetFn ''

  calculateOrderFullPrice: (details) ->
    orderFullPrice = 0.0
    $.each details, (index, detail) ->
      orderFullPrice += detail.sku.fullPrice * detail.quantity
    orderFullPrice

  calculateCartFullPrice: (cartDetails) ->
    cartFullPrice = 0.0
    $.each cartDetails, (index, detail) ->
      cartFullPrice += detail.skuProfile.fullPrice * detail.quantity
    cartFullPrice

  backToSite: (e) ->
    $main = $('main').first()
    $main.children().show()
    $main.find('div.wrapper.subview').hide()

  showWrapperView: (identifier) ->
    $main = $('main').first()
    $('div.dropMenu').slideUp()
    $container = $main.find(identifier)
    $main.children().hide()
    $container.parents().show()
    $container.show()

  resetLocationSelect: ($select) ->
    $select.html '<option>Localidad</option>'
    $select.parent().find('ul').html '<li rel="Localidad">Localidad</li>'

  showApiError: (xhr) ->
    errorJSON = xhr.responseText
    error = @safeParse(errorJSON)
    error.meta.message = DEFAULT_API_ERROR_MESSAGE if xhr.status >= 500
    @showError(error.meta.message)

  showError: (errorMsg, options) ->
    defaults =
      title: 'Error'
      icon: 'iconFont-candado'
    options = $.extend(defaults, options)
    @showMessageModal(errorMsg, options)

  showAjaxLoading: (message = 'Procesando información') ->
    $loadingLayer = $('#wbi-ajax-loading-layer')
    $loadingLayer.find('.wbc-loading-message').text(message)
    $loadingLayer.show()

  hideAjaxLoading: ->
    $('#wbi-ajax-loading-layer').hide()

  getCreditCardType: (cardNumber) ->
    #start without knowing the credit card type
    result = "unknown"

    if cardNumber and cardNumber.length > 14
      Winbits = window.Winbits or {};
      Winbits.visaRegExp = Winbits.visaRegExp or /^4[0-9]{12}(?:[0-9]{3})?$/
      Winbits.masterCardRegExp = Winbits.masterCardRegExp or /^5[1-5][0-9]{14}$/
      Winbits.amexRegExp = Winbits.amexRegExp or /^3[47][0-9]{13}$/

      #first check for Visa
      if Winbits.visaRegExp.test(cardNumber)
        result = "visa"

      #then check for MasterCard
      else if Winbits.masterCardRegExp.test(cardNumber)
        result = "mastercard"

      #then check for AmEx
      else result = "amex"  if Winbits.amexRegExp.test(cardNumber)

      result

  padLeft: (str, length, fillChar) ->
    fillChar = fillChar or ' '
    fillStr = new Array(length + 1).join(fillChar)
    (fillStr + str).slice(length * -1)



  getDateValue: ($form, selector) ->
    value = $form.find(selector).val()
    if value
      value = @padLeft(value, 2, '0')
    value

  getGender: ($form) ->
    gender = $form.find("[name=gender][checked]").val()
    if gender
      gender = if gender is 'H' then 'male' else 'female'
    gender

  calculateCartTotal: (total, bitsTotal) ->
    total - bitsTotal

  calculateCartSaving: (cartDetails, bitsTotal, itemsTotal, shippingTotal) ->
    if cartDetails
      cartFullPrice = @calculateCartFullPrice(cartDetails) + shippingTotal
      cartPrice = itemsTotal  + shippingTotal
      totalSaved = cartFullPrice - cartPrice + bitsTotal
      Math.floor(totalSaved * 100 / cartFullPrice)
    else
      0

  updateCartInfoView: (cartModel, value, $slider) ->
    maxSelection = $slider.find('input').data('max-selection')
    bitsTotal = Math.min(value, maxSelection)
    $cartInfoView = $slider.closest('.cart-info')
    total = cartModel.get 'total'
    cartTotal = @calculateCartTotal(total, bitsTotal)
    $cartInfoView.find('.cart-total').text('$' + cartTotal)
    cartDetails = cartModel.get 'cartDetails'
    itemsTotal = cartModel.get 'itemsTotal'
    shippingTotal = cartModel.get 'shippingTotal'
    cartSaving = @calculateCartSaving(cartDetails, bitsTotal, itemsTotal, shippingTotal)
    $cartInfoView.find('.cart-saving').text(cartSaving + '%')
    cartTotal

  updateOrderDetailView: (orderModel, value, $slider) ->
    maxSelection = $slider.find('input').data('max-selection')
    bitsTotal = Math.min(value, maxSelection)
    $orderDetailView = $slider.closest('#order-detail')
    total = orderModel.get 'total'
    cashTotal = total - bitsTotal
    $orderDetailView.find('.wb-order-cash-total').text(cashTotal)
    itemsTotal = orderModel.get 'itemsTotal'
    shippingTotal = orderModel.get 'shippingTotal'
    orderDetails = orderModel.get 'orderDetails'
    orderFullPrice = @calculateOrderFullPrice(orderDetails) + shippingTotal
    totalSaved = orderFullPrice - total + bitsTotal
    $orderDetailView.find('.wb-order-saving').text(totalSaved)

  renderSliderOnPayment: (value, active) ->
    $slider    = $($.find('.slider'))
    $subTotal    = $($.find('.checkoutSubtotal'))
    amount     = $slider.find('.amount')
    appendCopy = $($.find('#wbi-copy-payment'))
    if active
      $slider.children().show()
      appendCopy.remove()
    else
      $slider.children().hide()
      copy = "<div name='wbi-copy-payment' id='wbi-copy-payment' >Estás usando #{amount.html()} para esta orden. Si deseas agregar o quitar bits, <a href='#' >haz click aquí.</a></div>"
      append = $subTotal.append(copy)
      append.find("a").on "click": (e) ->
        $($.find('#wbi-cancel-card-token-payment-btn')).click()
        appendCopy.remove()

  isCrapBrowser: ->
    $.browser.msie and not /10.*/.test($.browser.version)

  paymentMethodSupportedHtml: (methods, ac, html) ->
    if not methods
      return new Handlebars.SafeString("")

    if (methods? and ac?)
      supported = method for method in methods when method.identifier.match ac
      if supported
        return new Handlebars.SafeString("")

    html

  toggleDropMenus:(e, dropMenuClass)->
    e.stopPropagation()
    $dropMenus = $('.miCuentaDiv, .miCarritoDiv')
    $dropMenus.not(dropMenuClass).stop(yes, yes).slideUp()
    $dropMenus.filter(dropMenuClass).stop(yes, yes).slideToggle()

  hideDropMenus:()->
    $('.miCuentaDiv, .miCarritoDiv').slideUp()

  safeParse: (jsonText, message = DEFAULT_API_ERROR_MESSAGE)->
    try
      JSON.parse(jsonText)
    catch e
      meta: message: message, status: 500

  showMessageModal: (message, options, modalSelector = '#wbi-alert-modal')->
    options ?= {}
    $modal = $(modalSelector)
    options.value ?= 'Aceptar'
    options.context ?= @
    options.onClosed ?= $.noop
    options.title ?= 'Mensaje'
    options.icon ?="icontFont-question"
    options.acceptAction ?= $.noop
    options.acceptAction = $.proxy(options.acceptAction, options.context)
#    onStart = $.proxy(options.onStart or $.noop, context)
#    onCancel = $.proxy(options.onCancel or $.noop, context)
#    onComplete = $.proxy(options.onComplete or $.noop, context)
#    onCleanup = $.proxy(options.onCleanup or $.noop, context)
    onClosed = $.proxy(options.onClosed, options.context)
    $(".wbc-modal-message", $modal).html(message)
    $(".wbc-default-action", $modal).unbind('click').click(options.acceptAction).click(@closeMessageModal).val options.value
    $(".wbc-modal-title", $modal).html(options.title)
    $(".wbc-modal-icon", $modal).html("<span class='#{options.icon}'></span>")
    $('<a>').wbfancybox(padding: 10, href: modalSelector, onClosed: onClosed).click()


  showConfirmationModal: (message, options = {}) ->
    $modal = $('#wbi-confirmation-modal')
    options.cancelValue ?= 'Cancelar'
    options.context ?= @
    options.cancelAction ?= $.noop
    options.cancelAction = $.proxy(options.cancelAction, options.context)
    $(".wbc-cancel-action", $modal).unbind('click').click(options.cancelAction).click(@closeMessageModal).val options.cancelValue
    @showMessageModal(message, options, $modal.selector)

  showLoadingMessage: (message, options)->
    defaults = icon:'iconFont-clock2',title:message
    options = $.extend(defaults, options)
    divLoader = "<div class='wbc-loader'></div>"
    @showMessageModal(divLoader, options, '#wbi-message-modal')

  ajaxRequest: Winbits.ajaxRequest

  getApiToken: ->
    mediator.data.get('login-data')?.apiToken

  saveApiToken: (apiToken) ->
    mediator.data.get('login-data').apiToken = apiToken
    localStorage.setItem(env.get('api-token-name'), apiToken)

    rpc.saveApiToken apiToken, ->
      console.log 'ApiToken saved :)'
    , -> console.log 'Unable to save ApiToken :('

  deleteApiToken: ->
    localStorage.removeItem(env.get('api-token-name'))

  redirectTo: ->
    Winbits.Chaplin.utils.redirectTo.apply null, arguments

  saveLoginData: Winbits.saveLoginData

  formatCurrency: (value) ->
    "$#{value}"

  formatPercentage: (value) ->
    "#{value}%"

  isLoggedIn: () ->
    mediator.data.get('login-data')?

  isSwitchUser: ()->
    if @isLoggedIn()
      mediator.data.get('login-data').switchUser?
    else
      no

  getVirtualCart: () ->
    localStorage['wb-vcart'] or '[]'

  saveVirtualCart: (cartData) ->
    vcart = "[]"
    if(cartData.itemsCount > 0)
      cartItems = (@toCartItem(x) for x in cartData.cartDetails)
      vcart = JSON.stringify(cartItems)
      localStorage['wb-vcart'] = vcart
    else
      localStorage.removeItem 'wb-vcart'
    rpc.storeVirtualCart(vcart)

  toCartItem: (cartDetail) ->
    cartItem = {}
    cartItem[cartDetail.skuProfile.id] = cartDetail.quantity
    cartItem

  getResourceURL: (path) ->
    apiURL = env.get('api-url')
    "#{apiURL}/#{path}"

  setupAjaxOptions: (defaultOptions = {}, options) ->
    ajaxOptions = $.extend({}, defaultOptions, options)
    ajaxOptions.headers = $.extend({}, defaultOptions.headers, options.headers)
    ajaxOptions

  getCurrentVerticalId: ->
    env.get('current-vertical-id')

  closeMessageModal: $.fancybox.close

# Prevent creating new properties and stuff.
Object.seal? utils

delete Winbits.ajaxRequest
delete Winbits.saveLoginData

module.exports = utils
