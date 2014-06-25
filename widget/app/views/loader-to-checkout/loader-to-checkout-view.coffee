'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class LoaderHideView extends View
  container: env.get('vertical-container')
  id: 'wbi-loader-to-checkout'
  className: 'loaderDiv loader-hide'
  template: require './templates/loader-to-checkout'

  initialize:()->
    super
