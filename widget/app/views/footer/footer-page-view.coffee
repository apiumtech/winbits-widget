View = require 'views/base/view'

module.exports = class FooterPageView extends View
  container: 'footer'
  className: 'wb-footer'
  template: require './templates/footer'
