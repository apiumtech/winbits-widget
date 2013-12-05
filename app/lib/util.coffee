vendor = require 'lib/vendor'

module.exports =
  $ : window.w$
  setCookie : setCookie = (c_name, value, exdays) ->
    exdays = exdays or 7
    localStorage[c_name] = value

  getCookie : getCookie = (c_name) ->
    localStorage[c_name]

  deleteCookie : (name) ->
    localStorage[name] = undefined

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
    $form = Backbone.$(form)
    $form.find(".errors").html ""
    $form.valid()

  resetForm: (form) ->
    $form = Backbone.$(form)
    $form.validate().resetForm()
    $form.get(0).reset()
    $form.find(".errors").html ""
    $form.valid()

  focusForm:  (form) ->
    $form = Backbone.$(form)
    $form.find('input:visible:not([disabled]), textarea:visible:not([disabled])').first().focus()

  alertErrors : ($) ->
    params = util.getUrlParams()
    alert params._wb_error  if params._wb_error

  serializeForm : ($form, context) ->
    formData = context or {}
    Backbone.$.each $form.serializeArray(), (i, f) ->
      formData[f.name] = f.value

    formData

  resetComponents  : ()->
    $elements =  @$.find(".reseteable")
    that = @
    that.$($elements).each((i, reseteable) ->
        $reseteable = that.$(reseteable)
        if $reseteable.is("[data-reset-val]")
          $reseteable.val $reseteable.attr("data-reset-val")
        else if $reseteable.is("[data-reset-text]")
          $reseteable.text $reseteable.attr("data-reset-text")
        else if $reseteable.is("[data-reset-unload]")
          $reseteable.html ""
        else
          $reseteable.val ""
      )

  calculateOrderFullPrice: (details) ->
    orderFullPrice = 0.0
    w$.each details, (index, detail) ->
      orderFullPrice += detail.sku.fullPrice * detail.quantity
    orderFullPrice

  calculateCartFullPrice: (cartDetails) ->
    cartFullPrice = 0.0
    w$.each cartDetails, (index, detail) ->
      cartFullPrice += detail.skuProfile.fullPrice * detail.quantity
    cartFullPrice

  backToSite: (e) ->
    $ = Backbone.$
    $main = $('main').first()
    $main.children().show()
    $main.find('div.wrapper.subview').hide()

  showWrapperView: (identifier) ->
    $ = Backbone.$
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
    $ = Backbone.$
    $errorModal = $('#wbi-error-modal')
    $errorModal.find('.error-msg').text(errorMsg)
    $errorModal.modal('show')

  showAjaxIndicator: (message) ->
    message = if message? then message else 'Cargando...'
    $ = Backbone.$
    $ajaxModal = $('#wbi-ajax-modal')
    $ajaxModal.find('.loading-msg').text(message)
    $ajaxModal.modal('show')

  hideAjaxIndicator: () ->
    Backbone.$('#wbi-ajax-modal').modal('hide').find('.loading-msg').text('Cargando...')

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#      CUSTOMSTEPPER: Sumar y restar valores del stepper
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  customStepper : (obj) ->
    $ = w$ # NO BORRAR - Fix desarrollo
    if $(obj).length
      $(obj).each ->
        $(this).wrap "<div class=\"stepper\"/>"
        $this = $(this).parent()
        $this.append "<span class=\"icon plus\"/><span class=\"icon minus\"/>"
        $max = parseInt($this.parent().find(".inputStepperMax").val())
        $min = parseInt($this.parent().find(".inputStepperMin").val())
        $this.find(".icon").click ->
          $newVal = undefined
          $button = $(this)
          $oldValue = parseInt($button.parent().find("input").val(), 10)
          if $button.hasClass("plus")
            $newVal = $oldValue + 1
          else if $button.hasClass("minus")
            if $oldValue >= 2
              $newVal = $oldValue - 1
            else
              $newVal = 1

          if $newVal >= $min and $newVal <= $max
            $currentInput = $button.parent().find("input")
            $currentInput.val($newVal).trigger "step", $oldValue # NO BORRAR - Fix desarrollo
            $currentInput.trigger "change" # NO BORRAR - Fix desarrollo

        $this.find("input").keydown (e) ->
          keyCode = e.keyCode or e.which
          arrow =
            up: 38
            down: 40

          $newVal = undefined
          $oldValue = parseInt($(this).val(), 10)
          switch keyCode
            when arrow.up
              $newVal = $oldValue + 1
            when arrow.down
              $newVal = $oldValue - 1

          if $newVal >= $min and $newVal <= $max
            $(this).val($newVal).trigger "step", $oldValue  if $newVal >= 1 # NO BORRAR - Fix desarrollo
            $(this).trigger "change" # NO BORRAR - Fix desarrollo
    $(obj) # NO BORRAR - Fix desarrollo

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
      Math.round(totalSaved * 100 / cartFullPrice)
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