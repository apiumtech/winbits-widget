View = require 'views/base/view'

module.exports = class FooterView extends View
  container: 'footer'
  className: 'wb-footer'
  template: require './templates/footer'
