View = require 'views/base/view'

module.exports = class LoginPageView extends View
  container: '.mainHeader .wrapper'
  className: 'login'
  autoRender: true
  template: require './templates/login'
  autoAttach: true

  initialize: ->
   super

   attach: ->
    super
    Winbits.$('#wbi-login-link').fancybox(padding: 0, href: '#loginForm')


