template = require 'views/templates/widget/cartdetail/balance'
View = require 'views/base/view'

module.exports = class BalanceCartView extends View
  autoRender: yes
  template: template

  render: ->
    super
