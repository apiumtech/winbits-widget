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
        socialAccountsStatus.Facebook = socialAccount.available
      else
        socialAccountsStatus.Twitter = socialAccount.available
    socialAccountsStatus

  requestConnectionLink:(formData, options)->
    defaults =
      type: "POST"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest @connectLink(formData), $.extend(defaults, options)

  connectLink: (data)->
    utils.getResourceURL("users/connect/#{data}")

  requestGetSocialAccounts:(options)->
    defaults =
      type: "GET"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(utils.getResourceURL("users/social-accounts"), $.extend(defaults, options))

  requestDeleteSocialAccount:(formData, options)->
    defaults =
      type: "Delete"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest @socialAccountUrl(formData), $.extend(defaults, options)

  socialAccountUrl: (data)->
    utils.getResourceURL("users/social-account/#{data}")