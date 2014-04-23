Controller = require 'controllers/logged-in-controller'
$ = Winbits.$
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class MyAccountController extends Controller

  index: (params)->
    $('#wbi-my-account-div').slideDown()
    if not mediator.data.get('tabs-swapped')
      mediator.data.set('tabs-swapped', yes)
      $("##{params.tabId}").click()

