'use strict'

wb =
  facebookAppId: '486640894740634'
  debug: true
  log: console.log

Object.seal? wb

window.Winbits = wb

console.log = ->
  if Winbits.debug
    args = arguments
    args = (arg for arg in args)
    args = if args.length > 0 then args.join() else args[0]
    Winbits.log(args)
