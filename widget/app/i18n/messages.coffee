'use strict'

# Internationalizable messages
# ------------------------------
ORDE001 = title: 'No se encuentra el producto'
ORDE004 = title: 'Producto agotado'
ORDE005 = title: 'Producto excedido'
ORDE006 = title: 'Máximo de compra'
Messages = errors:
  ORDE001: ORDE001
  ORDE002: ORDE001
  ORDE003: ORDE001
  ORDE004: ORDE004
  ORDE005: ORDE005
  ORDE006: ORDE006
  ORDE007:
    title: 'Mínimo de compra'
  ORDE009:
    title: 'Máximo por sitio'
  ORDE010:
    title: 'Máximo por cliente'
  ORDE011: ORDE006
  ORDE037: ORDE004
  ORDE038: ORDE005

i18n = {}
_ = Winbits._

# _(utils).extend
#  someMethod: ->
_(i18n).extend
  get: (code) ->
    Messages.errors[code]

# Prevent creating new properties and stuff.
Object.seal? i18n

module.exports = i18n
