# sku-profile-specific utilities
# --------------

utils = require 'lib/utils'
EventBroker = Winbits.Chaplin.EventBroker
$ = Winbits.$
env = Winbits.env
_ = Winbits._
mediator = Winbits.Chaplin.mediator
FACEBOOK_NAME = 'Facebook'
TWITTER_NAME = 'Twitter'

socialUtils = {}
_(socialUtils).extend
  getSocialAccountResourceUrl:(actionName) ->
    resource = if actionName is 'updateStatus' then "/twitterPublish/" else '/facebookPublish/'
    utils.getResourceURL("users#{resource}#{actionName}.json")

  validateUseSocialAccount: (socialAccountName)->
    if utils.isLoggedIn()
      for socialAccount in mediator.data.get('login-data').socialAccounts
        if socialAccount.name is socialAccountName
          if socialAccount.available
            return yes
          else
            throw "#{socialAccountName}, not connected!"
    else
      throw 'Not available if not logged in'

  share: (options) ->
    options = options or {}
    if (@validateUseSocialAccount(FACEBOOK_NAME))
      if not options.message  or not options.name
        throw "Argument's 'message' and 'name' are required!"
      data = options
      utils.ajaxRequest(utils.getResourceURL('social/announcement/facebook/promoteProduct'), @applyDefaultSocialAccountPublish(data, context:@))
      .done(@socialUtilsSuccess)
      .fail(@socialUtilsError)

  like: (options) ->
    options = options or {}
    if (@validateUseSocialAccount(FACEBOOK_NAME))
      unless options.id
        throw "Argument 'id' is required!"
      data = objectId: options.id
      utils.ajaxRequest(@getSocialAccountResourceUrl('like'), @applyDefaultSocialAccountPublish(data, context:@))
      .done(@socialUtilsSuccess)
      .fail(@socialUtilsError)

  tweet: (options) ->
    options = options or {}
    if (@validateUseSocialAccount(TWITTER_NAME))
      unless options.message
        throw "Argument 'message' is required!"
      data = message: options.message
      utils.ajaxRequest(@getSocialAccountResourceUrl('updateStatus'), @applyDefaultSocialAccountPublish(data, context:@))
      .done(@socialUtilsSuccess)
      .fail(@socialUtilsError)

  socialUtilsSuccess: ->
    console.log ['social account publish success']

  socialUtilsError: ->
    console.log ['social account publish error']


  applyDefaultSocialAccountPublish: (formData, options = {}) ->
    defaults =
      dataType: "json"
      type: 'POST'
      headers:
        'Wb-Api-Token': utils.getApiToken()
      data: JSON.stringify(formData)
    requestOptions = $.extend({}, defaults, options)
    requestOptions.headers = $.extend({}, defaults.headers, options.headers)
    requestOptions


#Prevent creating new properties and stuff
Object.seal? socialUtils
module.exports = socialUtils