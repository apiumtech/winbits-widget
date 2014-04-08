utils = Winbits.require 'lib/utils'
EventBroker = Winbits.Chaplin.EventBroker
_ = Winbits._

# Base model.
module.exports = class Model extends Chaplin.Model
  # Mixin a synchronization state machine.
  # _(@prototype).extend Chaplin.SyncMachine
  # initialize: ->
  #   super
  #   @on 'request', @beginSync
  #   @on 'sync', @finishSync
  #   @on 'error', @unsync

  needsAuth: false

  initialize: ->
    super
    _.extend @prototype, EventBroker

  sync: (method, model, options = {}) ->
    options.headers = 'Accept-Language': 'es'
    options.headers['Wb-Api-Token'] = utils.getApiToken() if @needsAuth
    super(method, model, options)
