'use strict'

require = Winbits.require
utils = require 'lib/utils'
Handlebars = Winbits.Handlebars
env = Winbits.env
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
_ = Winbits._
moment = Winbits.moment
# Application-specific view helpers
# http://handlebarsjs.com/#helpers
# --------------------------------

# Map helpers
# -----------

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
Handlebars.registerHelper 'url', (routeName, params..., options) ->
  Chaplin.helpers.reverse routeName, params

Handlebars.registerHelper "compare", (lvalue, rvalue, options) ->
  lvalue = lvalue() if $.isFunction(lvalue)
  rvalue = rvalue() if $.isFunction(rvalue)
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

Handlebars.registerHelper "getCurrentVerticalId", ->
  env.get 'current-vertical-id'

Handlebars.registerHelper "withCurrentVertical", (options) ->
  options.fn env.get 'current-vertical'

Handlebars.registerHelper "eachActiveVertical", (options) ->
  result = ''
  verticalsData = env.get('verticals-data') or []
  if verticalsData.length > 0
    for vertical in verticalsData
      result += options.fn vertical
  else result = options.inverse @
  result

Handlebars.registerHelper "formatCurrency", (value)->
  value = value() if $.isFunction(value)
  utils.formatCurrency(value)

Handlebars.registerHelper "getContactName", () ->
  $.trim(this.firstName + ' ' + this.lastName)

Handlebars.registerHelper "joinAttributes", (mainAttribute, attributes) ->
  attrs = [mainAttribute].concat(attributes)
  attrs = ("#{x.name}: #{x.label}" for x in attrs)
  attrs.join ', '

Handlebars.registerHelper "eachOption", (min, max, options) ->
  opts = (options.fn(value: x, text: x) for x in [min..max])
  opts.join ''

Handlebars.registerHelper "formatPercentage", (value) ->
  value = value() if $.isFunction(value)
  utils.formatPercentage(value)

Handlebars.registerHelper 'getItemTotalPrice', (val1, val2) ->
  val1 * val2

Handlebars.registerHelper 'setIndex', (val1) ->
  val1 + 1

Handlebars.registerHelper "getIndex", (index) ->
  index + 1

Handlebars.registerHelper "getBitsMaxSelection", (defaultMax) ->
  defaultMax = defaultMax() if $.isFunction(defaultMax)
  $profile = mediator.data.get('login-data')
  $maxValue = defaultMax
  if $profile?
    $maxValue = $profile.bitsBalance
  $maxValue

Handlebars.registerHelper "generateTicketPaymentDownloadUrl", (paymentCapture) ->
  capture = JSON.parse (paymentCapture)
  capture.downloadUrl

isPaymentSupported = (methods, identifier, options) ->
  supported = no
  for paymentMethod in  methods
    if paymentMethod.identifier.indexOf(identifier) is 0
      supported = yes
      break
  supported

Handlebars.registerHelper "paymentMethodSupported", (identifier, options) ->
  supported = isPaymentSupported(@paymentMethods, identifier, options)
  if supported then options.fn this else options.inverse this

allMsiPaymentsFunction = (methods) ->
  $.grep methods, (paymentMethod)->
   if paymentMethod.identifier.indexOf('.msi') isnt -1
     return paymentMethod.identifier

msiPaymentsFunction = (allMsiPayments) ->
  msiIdentifiers = []
  msiPayments = []
  $.each allMsiPayments, (index, msiPayment) ->
    identifier = msiPayment.identifier.substring 0, msiPayment.identifier.indexOf('.')
    if msiIdentifiers.indexOf(identifier) is -1
      msiIdentifiers.push identifier
      msiPayments.push msiPayment
  msiPayments

Handlebars.registerHelper "withMsiPayments", (options) ->
  allMsiPayments = allMsiPaymentsFunction @paymentMethods
  msiPayments = msiPaymentsFunction allMsiPayments
  if msiPayments.length > 0 then options.fn(msiPayments: msiPayments) else options.inverse this

Handlebars.registerHelper "toDefaultDateFormat", (dateString) ->
  if dateString
    moment(new Date(dateString)).format('DD/MM/YYYY');

Handlebars.registerHelper "abs", (number) ->
  Math.abs(number)

checkAvailableCoupons = (coupons) ->
  _.every coupons, (coupon) -> coupon.status is 'AVAILABLE'

Handlebars.registerHelper "availableCoupon", (options) ->
  available = checkAvailableCoupons @coupons
  if available then options.fn this else options.inverse this

Handlebars.registerHelper "getAvailableCouponsDate",(coupons) ->
  createdCoupon =_.find coupons, (coupon) -> coupon.status is 'CREATED'
  createdCoupon.availableCouponDate
