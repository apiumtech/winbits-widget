# Application-specific utilities
# ------------------------------

# Delegate to Chaplin’s utils module.
utils = Winbits.Chaplin.utils.beget Chaplin.utils
$ = Winbits.$
_ = Winbits._
mediator = Winbits.Chaplin.mediator

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

  showAjaxError: (jsonError) ->
    error = JSON.parse(jsonError)
    @showError(error.meta.message)

  showError: (errorMsg) ->
    $errorModal = $('#wbi-error-modal')
    $errorModal.find('.error-msg').text(errorMsg)
    $errorModal.modal('show')

  showAjaxIndicator: (message) ->
    message = if message? then message else 'Cargando...'
    $ajaxModal = $('#wbi-ajax-modal')
    $ajaxModal.find('.loading-msg').html(message)
    $ajaxModal.modal('show')

  hideAjaxIndicator: () ->
    $('#wbi-ajax-modal').modal('hide').find('.loading-msg').text('Cargando...')

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

  getBirthday: ($form) ->
    @getYear($form) + '-' + @getMonth($form) + '-' + @getDay($form)

  getDay: ($form) ->
    @getDateValue($form, ".day-input") or ''

  getMonth: ($form) ->
    @getDateValue($form, ".month-input") or ''

  getYear: ($form) ->
    year = @getDateValue($form, ".year-input") or ''
    if year.length
      currentYear = parseInt(moment().format('YYYY').slice(-2))
      year =  (if year > currentYear then "19" else "20") + year
    year

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

  safeParse: (jsonText)->
    try
      JSON.parse(jsonText)
    catch e
      meta: message: 'El servidor no está disponible, por favor inténtalo más tarde.', status: 500

  showMessageModal: (message, options)->
    options ?= {}
    modalSelector = '#wbi-message-modal'
    $modal = $(modalSelector)
    options.value ?= 'Ok'
    options.context ?= @
    options.onClosed ?= $.noop
#    onStart = $.proxy(options.onStart or $.noop, context)
#    onCancel = $.proxy(options.onCancel or $.noop, context)
#    onComplete = $.proxy(options.onComplete or $.noop, context)
#    onCleanup = $.proxy(options.onCleanup or $.noop, context)
    onClosed = $.proxy(options.onClosed, options.context)
    $(".wbc-modal-message", $modal).html(message)
    $(".wbc-default-action", $modal).val options.value
    $('<a>').wbfancybox(padding: 10, href: modalSelector, onClosed: onClosed).click()

  ajaxRequest: Winbits.ajaxRequest

  getApiToken: ->
    mediator.data.get('login-data').apiToken

  saveApiToken: (apiToken) ->
    mediator.data.get('login-data').apiToken = apiToken
    localStorage.setItem(Winbits.env.get('api-token-name'), apiToken)

    mediator.data.get('rpc').saveApiToken apiToken, ->
      console.log 'ApiToken saved :)'
    , -> console.log 'Unable to save ApiToken :('

  deleteApiToken: ->
    localStorage.removeItem(Winbits.env.get('api-token-name'))



  redirectTo: ->
    Winbits.Chaplin.utils.redirectTo.apply null, arguments

# Prevent creating new properties and stuff.
Object.seal? utils

delete Winbits.ajaxRequest

module.exports = utils
