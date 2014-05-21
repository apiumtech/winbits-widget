'use strict'
utils =  require 'lib/utils'
Model =  require 'models/base/model'
mediator = Winbits.Chaplin.mediator
_= Winbits._
$ = Winbits.$
env = Winbits.env

module.exports = class SocialAccounts extends Model

  initialize: (loginData = mediator.data.get 'login-data') ->
    super
    @set(@parse response: loginData) if loginData

  parse: (data)->
    response = super
    socialAccountsStatus = []
    socialAccounts = _.clone(response.socialAccounts)
    for socialAccount in socialAccounts
      if socialAccount.name is 'Facebook'
        socialAccountsStatus.facebook = socialAccount.available
      else
        socialAccountsStatus.twitter = socialAccount.available
    socialAccountsStatus

  requestConnectionLink:(formData, options)->
    defaults =
      type: "POST"
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest @connectLink(formData), $.extend(defaults, options)

  connectLink: (data)->
    "#{env.get('api-url')}/users/connect/#{data}"