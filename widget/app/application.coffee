routes = require './routes'
util = require 'lib/util'


# The application object.
module.exports = class Application extends Chaplin.Application
  # Set your application name here so the document title is set to
  # “Controller title – Site title” (see Chaplin.Layout#adjustTitle)
  title: 'Concept test'

  initialize: ->
    super
    Winbits.isCrapBrowser = util.isCrapBrowser
    @initXDMRpc
      remote: Winbits.userConfig.providerUrl



  initXDMRpc: (config) ->
    Winbits.rpc = new easyXDM.Rpc(config,
      remote:
        request: {}
        getTokens: {}
        saveApiToken: {}
        storeVirtualCart: {}
        logout: {}
        saveUtms: {}
        getUtms: {}
        facebookStatus: {}
        facebookMe: {}
        saveUtms: {}
        getUtms: {}
    )