utils = Winbits.require 'lib/utils'

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

  sync: (method, model, options = {}) ->
    options.headers = 'Accept-Language': 'es'
    options.headers['Wb-Api-Token'] = utils.getApiToken() if @needsAuth
    super(method, model, options)
