vendor = require 'lib/vendor'

DEFAULT_API_ERROR_MESSAGE = 'El servidor no está disponible, por favor inténtalo más tarde.'

module.exports =
  $ : window.Winbits.$


  setCookie : setCookie = (c_name, value, exdays) ->
    exdays = exdays or 7
    exdate = new Date()
    exdate.setDate exdate.getDate() + exdays
    c_value = escape(value) + ((if (exdays is null) then "" else "; path=/; expires=" + exdate.toUTCString()))
    document.cookie = c_name + "=" + c_value

  getCookieByName : getCookieByName = (c_name) ->
    c_value = document.cookie
    c_start = c_value.indexOf(" " + c_name + "=")
    c_start = c_value.indexOf(c_name + "=")  if c_start is -1
    if c_start is -1
      c_value = null
    else
      c_start = c_value.indexOf("=", c_start) + 1
      c_end = c_value.indexOf(";", c_start)
      c_end = c_value.length  if c_end is -1
      c_value = unescape(c_value.substring(c_start, c_end))
    c_value

  deleteCookie : (name) ->
    document.cookie = name + "=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT"


  storeKey : (key, value) ->
    try
      localStorage[key] = value
    catch e
      setCookie(key, value, 7)

  retrieveKey : (key) ->
    try
      localStorage[key]
    catch e
      getCookieByName(key)

  deleteKey : (key) ->
    try
      localStorage.removeItem(key)
    catch e
      deleteCookie(key)

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
    $form = Winbits.$(form)
    $form.find(".errors").html ""
    $form.valid()

  justResetForm: (form) ->
    $form = Winbits.$(form)
    $form.validate().resetForm()
    $form.get(0).reset()
    $form.find(".errors").html ""

  resetForm: (form) ->
    $form = Winbits.$(form)
    @justResetForm($form)
    $form.valid()

  focusForm:  (form) ->
    $form = Winbits.$(form)
    if not @isCrapBrowser()
      $form.find('input:visible:not([disabled]), textarea:visible:not([disabled])').first().focus()

  alertErrors : ($) ->
    params = util.getUrlParams()
    alert params._wb_error  if params._wb_error

  serializeForm : ($form, context) ->
    formData = context or {}
    Winbits.$.each $form.serializeArray(), (i, f) ->
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
    Winbits.$.each details, (index, detail) ->
      orderFullPrice += detail.sku.fullPrice * detail.quantity
    orderFullPrice

  calculateCartFullPrice: (cartDetails) ->
    cartFullPrice = 0.0
    Winbits.$.each cartDetails, (index, detail) ->
      cartFullPrice += detail.skuProfile.fullPrice * detail.quantity
    cartFullPrice

  backToSite: (e) ->
    $ = Winbits.$
    $main = $('main').first()
    $main.children().show()
    $main.find('div.wrapper.subview').hide()

  showWrapperView: (identifier) ->
    $ = Winbits.$
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
    $ = Winbits.$
    $errorModal = $('#wbi-error-modal')
    $errorModal.find('.error-msg').text(errorMsg)
    $errorModal.modal('show')

  showAjaxIndicator: (message) ->
    message = if message? then message else 'Cargando...'
    $ = Winbits.$
    $ajaxModal = $('#wbi-ajax-modal')
    $ajaxModal.find('.loading-msg').html(message)
    $ajaxModal.modal('show')

  hideAjaxIndicator: () ->
    Winbits.$('#wbi-ajax-modal').modal('hide').find('.loading-msg').text('Cargando...')

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#      CUSTOMSTEPPER: Sumar y restar valores del stepper
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  customStepper : (obj) ->
    $ = Winbits.$ # NO BORRAR - Fix desarrollo
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
    $orderDetailView.find('.wb-order-saving').text(totalSaved.toFixed(2))

  renderSliderOnPayment: (value, active) ->
    $slider    = Winbits.$(Winbits.$.find('.slider'))
    $subTotal    = Winbits.$(Winbits.$.find('.checkoutSubtotal'))
    amount     = $slider.find('.amount')
    appendCopy = Winbits.$(Winbits.$.find('#wbi-copy-payment'))
    if active 
      $slider.children().show()
      appendCopy.remove() 
    else
      $slider.children().hide()
      if amount.html() 
        copy = "<p class='nobits' name='wbi-copy-payment' id='wbi-copy-payment' >Estás usando <em>#{amount.html()}</em> para esta orden. Si deseas agregar o quitar bits, <a href='#' >haz click aquí.</a></p>"  
      else
        copy = ''
      append = $subTotal.append(copy)
      append.find("a").on "click": (e) ->
        Winbits.$(Winbits.$.find('#wbi-cancel-payment-btn')).click()
        appendCopy.remove()

  isCrapBrowser: ->
    Winbits.$.browser.msie and Winbits.$.browser.versionNumber < 10

  ajaxRequest:(url, options) ->
    $ = Winbits.$
    if $.isPlainObject(url)
      options = url
      url = options.url
    defaultOptions =
      dataType: 'json'
      context: @
    defaultHeaders =
      'Accept-Language': 'es'
      'Content-Type': 'application/json'
    options = $.extend(defaultOptions, options)
    options.headers = $.extend(defaultHeaders, options.headers)

    if Winbits.isCrapBrowser()
      context = options.context
      deferred = new $.Deferred()
        .done(options.success)
        .fail(options.error)
        .always(options.complete)
      unsupportedOptions = ['context', 'success', 'error', 'complete']
      delete options[property] for property in unsupportedOptions

      Winbits.rpc.request(url, options, (response) ->
        args = [response.data, response.textStatus, response.jqXHR]
        deferred.resolveWith(context, args)
      , (response) ->
        message = response.message
        args = [message.jqXHR, message.textStatus, message.errorThrown]
        deferred.rejectWith(context, args)
      )
      deferred.promise()
    else
      Winbits.$.ajax(url,options)


  paymentMethodSupportedHtml: (methods, ac, html) ->
      if not methods
        return new Handlebars.SafeString("")

      if (methods? and ac?)
          supported = method for method in methods when method.identifier.match ac 
          if supported
            return new Handlebars.SafeString("")
          
      return html

  toggleDropMenus:(e, dropMenuClass)->
    e.stopPropagation()
    $dropMenus = Winbits.$('.miCuentaDiv, .miCarritoDiv')
    $dropMenus.not(dropMenuClass).stop(yes, yes).slideUp()
    $dropMenus.filter(dropMenuClass).stop(yes, yes).slideToggle()

  hideDropMenus:()->
    Winbits.$('.miCuentaDiv, .miCarritoDiv').slideUp()
  
  safeParse: (jsonText, message = DEFAULT_API_ERROR_MESSAGE)->
    try
      JSON.parse(jsonText)
    catch e
      meta: message: message, status: 500

  formatCurrency: (value) ->
    if value
      value = value.toString().replace('.00', '')
    "$#{value}"

  formatNumWithComma: (value) ->
    value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

  tagManagerConnection: () ->
    ((w, d, s, l, i) ->
      w[l] = w[l] or []
      w[l].push
        'gtm.start': (new Date).getTime()
        event: 'gtm.js'
      f = d.getElementsByTagName(s)[0]
      j = d.createElement(s)
      dl = if l != 'dataLayer' then '&l=' + l else ''
      j.async = true
      j.src = '//www.googletagmanager.com/gtm.js?id=' + i + dl
      f.parentNode.insertBefore j, f
      return
    ) window, document, 'script', 'dataLayer', 'GTM-KQ7HXQ'

  googleAnalyticsConnection: () ->
    ((i, s, o, g, r, a, m) ->
      i['GoogleAnalyticsObject'] = r
      i[r] = i[r] or ->
          (i[r].q = i[r].q or []).push arguments

      i[r].l = 1 * new Date
      a = s.createElement(o)
      m = s.getElementsByTagName(o)[0]
      a.async = 1
      a.src = g
      m.parentNode.insertBefore a, m
      return
    ) window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga'

  adRollConnection:(segments) ->
    adroll_segments = segments
    adroll_adv_id = 'C7RIE3U37FHQJJC46ID7SX'
    adroll_pix_id = 'BXEYKGTA2BHITNBCIZEFQP'
    do ->
      oldonload = window.onload
      window.onload = ->
         __adroll_loaded = true
         scr = document.createElement('script')
         host = if 'https:' == document.location.protocol then 'https://s.adroll.com' else 'http://a.adroll.com'
         scr.setAttribute 'async', 'true'
         scr.type = 'text/javascript'
         scr.src = host + '/j/roundtrip.js'
         ((document.getElementsByTagName('head') or [ null ])[0] or document.getElementsByTagName('script')[0].parentNode).appendChild scr
         if oldonload
           oldonload()
    return

  adRollSteps:() ->
    @adRollConnection('')

  adRollPurchase:() ->
    @adRollConnection('634fac2a')

  tagPixelFacebookConnection: () ->
    !((f, b, e, v, n, t, s) ->
      if f.fbq
        return
      n =
        f.fbq = ->
          if n.callMethod then n.callMethod.apply(n, arguments) else n.queue.push(arguments)

      if !f._fbq
        f._fbq = n
      n.push = n
      n.loaded = !0
      n.version = '2.0'
      n.queue = []
      t = b.createElement(e)
      t.async = !0
      t.src = v
      s = b.getElementsByTagName(e)[0]
      s.parentNode.insertBefore t, s
    )(window, document, 'script', '//connect.facebook.net/en_US/fbevents.js')


  createPixelFacebookPurchase: () ->
    @tagPixelFacebookConnection()
    fbq 'init', '684475971610225'
    fbq 'track', 'Purchase',
      {
        content_ids: @createContentsIdsFacebook(),
        value: document.getElementsByClassName("slideInput-totalPrice")[0].innerHTML.replace('$', '').replace(',',''),
        currency: 'MXN'
      }
    return

  tagManagerSteps: (step, method) ->
    window.dataLayer = []
    $products = []
    $products = @createDatalayerProducts()
    window.dataLayer.push {
      'event': 'checkout',
      'ecommerce':{
        'checkout': {
          'actionField': {
            'step': step,
            'option': method
          },
          'products': $products
        }
      }
    }
    @tagManagerConnection()
    return

  createAnalyticsDataLayerPurchase:() ->
    window.ga =[]
    window.ga.push {
      'id': Winbits.checkoutConfig.orderId,
      'affiliation': @verticalIdToName(Winbits.checkoutConfig.verticalId),
      'revenue': document.getElementsByClassName("slideInput-totalPrice")[0].innerHTML.replace('$', '').replace(',',''),
      'shipping': document.getElementsByClassName("checkoutSubtotal")[0].childNodes[11].innerHTML.replace('$', ''),
      'tax': '0.00'
    }
    @googleAnalyticsConnection()
    return


  createDatalayerPurchase: () ->
    window.dataLayer = []
    $products = []
    $products = @createDatalayerProducts()
    window.dataLayer.push {
      'event': 'compra',
      'ecommerce': {
        'purchase': {
          'actionField': {
            'id': Winbits.checkoutConfig.orderId,
            'affiliation': @verticalIdToName(Winbits.checkoutConfig.verticalId),
            'revenue': document.getElementsByClassName("slideInput-totalPrice")[0].innerHTML.replace('$', '').replace(',',''),
            'tax': '0.00',
            'shipping': document.getElementsByClassName("checkoutSubtotal")[0].childNodes[11].innerHTML.replace('$', '')
          },
          'products': $products
        }
      }
    }
    @tagManagerConnection()
    return

  verticalIdToName:(id) ->
    vertical = ''
    switch id
      when '4'
        vertical = 'ClickOnero'
      when '11'
        vertical = 'Bebitos'
      when '12'
        vertical = 'Invita Amigos'
      else
        break
    vertical

  createContentsIdsFacebook: () ->
    $orderDetails = window.completeOrderDetails
    $contents = []
    for detail in $orderDetails
      $contents.push detail.sku.id.toString()
    return $contents


  createDatalayerProducts: () ->
    $orderDetails = window.completeOrderDetails
    $products = []
    for detail in $orderDetails
      $products.push {
          'name': detail.sku.name,
          'id': detail.sku.id + "",
          'price': detail.sku.price + "",
          'brand': detail.sku.brand.name,
          'category': detail.sku.brand.description,
          'variant': detail.sku.mainAttribute.label,
          'quantity': detail.quantity
      }
    return $products

  isMobile: () ->
    @mobileWeb = /Mobile|iP(hone|od|ad)|Android|BlackBerry|IEMobile|Kindle|NetFront|Silk-Accelerated|(hpw|web)OS|Fennec|Minimo|Opera M(obi|ini)|Blazer|Dolfin|Dolphin|Skyfire|Zune/i.test(navigator.userAgent)
    if @mobileWeb
      return true
    else
      return false