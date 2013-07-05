template = require 'views/templates/login'
View = require 'views/base/view'

module.exports = class LoginView extends View
  autoRender: yes
  className: 'home-page'
  #container: '#winbits-widget'
  template: template

  render: ->
    console.log "(>_<)"
    super


