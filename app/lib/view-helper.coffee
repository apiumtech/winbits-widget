#Chaplin = require 'chaplin'

# Application-specific view helpers
# http://handlebarsjs.com/#helpers
# --------------------------------

# Map helpers
# -----------
cartDetail = require 'views/templates/widget/cartDetail'
mediator = require 'chaplin/mediator'
util = require 'lib/util'

# Make 'with' behave a little more mustachey.
Handlebars.registerHelper 'with', (context, options) ->
  if not context or Handlebars.Utils.isEmpty context
    options.inverse(this)
  else
    options.fn(context)

# Inverse for 'with'.
Handlebars.registerHelper 'without', (context, options) ->
  inverse = options.inverse
  options.inverse = options.fn
  options.fn = inverse
  Handlebars.helpers.with.call(this, context, options)

# Get Chaplin-declared named routes. {{#url "like" "105"}}{{/url}}
#Handlebars.registerHelper 'url', (routeName, params..., options) ->
##Chaplin.helpers.reverse routeName, params
#******************************
#Handlebars helpers https://gist.github.com/1468937#comments
#******************************

# debug helper
# usage: {{debug}} or {{debug someValue}}
# from: @commondream (http://thinkvitamin.com/code/handlebars-js-part-3-tips-and-tricks/)
Handlebars.registerHelper "debug", (optionalValue) ->
  console.log "Current Context"
  console.log "===================="
  console.log this
  if optionalValue
    console.log "Value"
    console.log "===================="
    console.log optionalValue


# return the first item of a list only
# usage: {{#first items}}{{name}}{{/first}}
Handlebars.registerHelper "first", (context, block) ->
  if context isnt undefined && context.length > 0
    block.fn context[0]


# a iterate over a specific portion of a list.
# usage: {{#slice items offset="1" limit="5"}}{{name}}{{/slice}} : items 1 thru 6
# usage: {{#slice items limit="10"}}{{name}}{{/slice}} : items 0 thru 9
# usage: {{#slice items offset="3"}}{{name}}{{/slice}} : items 3 thru context.length
# defaults are offset=0, limit=5
# todo: combine parameters into single string like python or ruby slice ("start:length" or "start,length")
Handlebars.registerHelper "slice", (context, block) ->
  ret = ""
  offset = parseInt(block.hash.offset) or 0
  limit = parseInt(block.hash.limit) or 5

  if context isnt undefined && context.length > 0
    i = (if (offset < context.length) then offset else 0)
    j = (if ((limit + offset) < context.length) then (limit + offset) else context.length)
    while i < j
      ret += block.fn(context[i])
      i++

  ret


# return a comma-serperated list from an iterable object
# usage: {{#toSentance tags}}{{name}}{{/toSentance}}
Handlebars.registerHelper "toSentance", (context, block) ->
  ret = ""
  i = 0
  j = context.length

  while i < j
    ret = ret + block.fn(context[i])
    ret = ret + ", "  if i < j - 1
    i++
  ret


# format an ISO date using Moment.js
# http://momentjs.com/
# moment syntax example: moment(Date("2011-07-18T15:50:52")).format("MMMM YYYY")
# usage: {{dateFormat creation_date format="MMMM YYYY"}}
Handlebars.registerHelper "dateFormat", (context, block) ->
  if moment
    f = block.hash.format or "MMM Do, YYYY"
    return moment(new Date(context)).format(f)
  else
    return context # moment plugin not available. return data as is.

Handlebars.registerHelper "deliveryDateFormat", (context, block) ->
  if moment
    f = block.hash.format or "DD/MM/YYYY"
    days = parseInt(block.hash.days or 20)
    return moment(new Date(context)).add('days', days).format(f)
  else
    return context # moment plugin not available. return data as is.

Handlebars.registerHelper "sliceHalfLeft", (context, block) ->
  ret = ""
  limit = Math.round context.length / 2
  i = 0

  while i < limit
    ret += block.fn context[i++]

  ret

Handlebars.registerHelper "sliceHalfRight", (context, block) ->
  ret = ""
  limit = context.length
  i = Math.round context.length / 2

  while i < limit
    ret += block.fn context[i++]

  ret

Handlebars.registerHelper "sliceBlock", (context, block) ->
  ret = ""
  part = parseInt(block.hash.part)
  offset = Math.round context.length / 4
  limit = (if offset * part is context.length-1 then context.length else offset * part)
  i = (part - 1) * offset
  if context.length > i and limit <= context.length
    while i < limit
      ret += block context[i++]

  ret

#******************************
#Custom Helper
#******************************
# Comparison Helper for handlebars.js
# Pass in two values that you want and specify what the operator should be
# e.g. {{#compare val1 val2 operator="=="}}{{/compare}}
Handlebars.registerHelper "compare", (lvalue, rvalue, options) ->
  throw new Error("Handlerbars Helper 'compare' needs 2 parameters")  if arguments.length < 3
#    asString = options.hash.asString or true
  asString = options.hash.asString != "false"
  operator = options.hash.operator or "=="

  operators =
    "==": (l, r) ->
      l is r
    "===": (l, r) ->
      l is r
    "!=": (l, r) ->
      l isnt r
    "<": (l, r) ->
      l < r
    ">": (l, r) ->
      l > r
    "<=": (l, r) ->
      l <= r
    "in": (l, r) ->
      l in r
    "matches": (l, r) ->
      new RegExp(r).test(l)
    typeof: (l, r) ->
      typeof l is r

  throw new Error("Handlerbars Helper 'compare' doesn't know the operator " + operator)  unless operators[operator]
  if asString
    result = operators[operator](String(lvalue), String(rvalue))
  else
    result = operators[operator](lvalue, rvalue)
  if result
    options.fn this
  else
    options.inverse this

Handlebars.registerHelper "substr", (context, options) ->
  if context
    theString = context.substr(options.hash.start, options.hash.length)
    new Handlebars.SafeString(theString)
  else
    ""

Handlebars.registerHelper "replace", (context, options) ->
  if context
    theString = context.replace(options.hash.searchValue, options.hash.replaceValue)
    new Handlebars.SafeString(theString)
  else
    ""
Handlebars.registerHelper "cartShipping", (total, shippingTotal) ->
  if shippingTotal
    '$' + shippingTotal
  else
    'GRATIS'

Handlebars.registerHelper "cartTotal", (total, bitsTotal) ->
  util.calculateCartTotal(total, bitsTotal)

Handlebars.registerHelper "calculateCartSaving", (cartDetails, bitsTotal, itemsTotal, shippingTotal) ->
  util.calculateCartSaving(cartDetails, bitsTotal, itemsTotal, shippingTotal)

Handlebars.registerHelper "cartDetailTotal", (unitPrice, quantity) ->
  unitPrice * quantity

Handlebars.registerHelper "joinAttributes", (mainAttribute, attributes) ->
  attrLabels = [mainAttribute.label]
  w$.each attributes, (index, attribute) ->
    attrLabels.push attribute.label
  attrLabels.join ', '

Handlebars.registerHelper "defaultThumbnail", (thumbnail) ->
  thumbnail || 'images/assets/jeans-tiny.jpg'

Handlebars.registerHelper "getStyleByStatus", (status, options) ->
  link = ""
  if status == "AVAILABLE"
    link = new Handlebars.SafeString("<a href='#' class='availableWish'>" + status + "</a>")
  else
    link = status
  link

Handlebars.registerHelper "select", (value, options) ->
  select = document.createElement("select")
  select.innerHTML = options.fn(this)
  select.value = value
  select.children[select.selectedIndex].setAttribute "selected", "selected"  if select.children[select.selectedIndex]
  select.innerHTML

Handlebars.registerHelper "getContactName", () ->
  (this.firstName + ' ' + this.lastName).trim()

Handlebars.registerHelper "getLocation", () ->
  this.location

Handlebars.registerHelper "getZipCode", () ->
  this.zipCode

Handlebars.registerHelper "getZipCodeInfoId", () ->
  if this.zipCodeInfo then this.zipCodeInfo.id else ''

Handlebars.registerHelper "formatAddressNumber", () ->
  addressNumber = this.externalNumber
  if this.internalNumber
    addressNumber += ' int. ' + this.internalNumber
  addressNumber

Handlebars.registerHelper "toDefaultDateFormat", (dateString) ->
  if dateString
    date = new Date(dateString)
    date.getDate() + '/' + date.getMonth() + '/' + date.getFullYear()

Handlebars.registerHelper "abs", (number) ->
  Math.abs(number)

Handlebars.registerHelper "getProfileEmail", () ->
  if mediator.global and mediator.global.profile
    mediator.global.profile.email
  else
    ''

Handlebars.registerHelper "getProfileEmail", () ->
  if mediator.global and mediator.global.profile
    mediator.global.profile.email
  else
    ''

Handlebars.registerHelper "getNewsletterFormatText", () ->
  if this.newsletterFormat is 'unified' then 'Un solo correo' else 'Correos individuales'

Handlebars.registerHelper "getNewsletterPeriodicityText", () ->
  if this.newsletterPeriodicity is 'weekly' then 'Cada semana' else 'Todos los días'

Handlebars.registerHelper "checkRadio", (value, radioValue) ->
  if value is radioValue then 'checked="checked"' else ''

Handlebars.registerHelper "getSocialActionByState", (state) ->
  if state is 'On' then 'Desligar' else 'Ligar'

Handlebars.registerHelper "hasBitsBalanceInCheckout", (options) ->
  if window.bits_balance > 0
    options.fn this
  else
    options.inverse this

Handlebars.registerHelper "hasBitsBalanceInResume", (options) ->
  if mediator.profile.bitsBalance > 0
    options.fn this
  else
    options.inverse this

Array::unique = ->
      output = {}
      output[@[key]] = @[key] for key in [0...@length]
      value for key, value of output

amexOrCyberSource = (cardType)->
    if cardType in ["Visa","MasterCard"] 
        return "cybersource.msi.token."
    if cardType == "American Express"
        return "amex.msi."

Handlebars.registerHelper "hasMSI", (supportInstallments, methods, cardType) ->
  ac = amexOrCyberSource cardType

  msi = ""
  if (methods?)
      msi = (method.identifier.substring(ac?.length, method?.identifier?.length) for method in methods when method.identifier.match ac).unique()

  if (supportInstallments == true and (msi?.length or method == undefined))
      return new Handlebars.SafeString("<span class='mesesSinIntereses-box'> #{msi} MESES SIN INTERESES</span>");

Handlebars.registerHelper "getIndex", (index) ->
  index + 1

Handlebars.registerHelper "isMSIPayment", (payment, options) ->
  if payment.identifier.lastIndexOf('msi') isnt -1
    lastDotIndex = payment.identifier.lastIndexOf('.')
    numberOfPayments = parseInt(payment.identifier.substr(lastDotIndex + 1))
    monthlyPayment = payment.amount / numberOfPayments
    options.fn [numberOfPayments: numberOfPayments, monthlyPayment: monthlyPayment]
  else
    options.inverse this

Handlebars.registerHelper "paymentMethodSupported", (identifier, options) ->
  supported = no
  Backbone.$.each @paymentMethods, (index, paymentMethod) ->
    supported = paymentMethod.identifier.indexOf(identifier) isnt -1
    not supported
  if supported then options.fn this else options.inverse this

Handlebars.registerHelper "withMsiPayments", (options) ->
  $ = Backbone.$
  msiIdentifiers = []
  msiPayments = []
  allMsiPayments = $.grep @.paymentMethods, (paymentMethod) ->
    paymentMethod.identifier.indexOf('.msi') isnt -1

  $.each allMsiPayments, (index, msiPayment) ->
    identifier = msiPayment.identifier.substring 0, msiPayment.identifier.indexOf('.')
    if msiIdentifiers.indexOf(identifier) is -1
      msiIdentifiers.push identifier
      msiPayments.push msiPayment

  if msiPayments.length > 0 then options.fn(msiPayments: msiPayments) else options.inverse this

Handlebars.registerHelper "getCreditCardType", (cardNumber) ->
  util.getCreditCardType(cardNumber)

Handlebars.registerHelper "getCardTypeClass", (cardType) ->
  cardType = cardType.toLowerCase()
  if cardType is 'amex' then 'wb-amex-card' else 'wb-cybersource-card'

Handlebars.registerHelper "options", (min, max, options) ->
  result = ''
  i = min
  console.log ['MIN', min, 'MAX', max]
  while i <= max
    result += options.fn(value: i, text: i)
    i++
  result

Handlebars.registerHelper "getBitsMaxSelection", (defaultMax) ->
  if mediator.global and mediator.global.profile
    mediator.global.profile.bitsBalance
  else
    defaultMax

#******************************
#Custom partial
#******************************
Handlebars.registerPartial("cartDetail",cartDetail )

