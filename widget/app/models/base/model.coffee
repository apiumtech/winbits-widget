utils = Winbits.require 'lib/utils'
$ = Winbits.$

# Base model.
module.exports = class Model extends Chaplin.Model
  # Mixin a synchronization state machine.
  # _(@prototype).extend Chaplin.SyncMachine
  # initialize: ->
  #   super
  #   @on 'request', @beginSync
  #   @on 'sync', @finishSync
  #   @on 'error', @unsync

  needsAuth: no

  sync: (method, model, options = {}) ->
    headers = 'Accept-Language': 'es'
    headers['Wb-Api-Token'] = utils.getApiToken() if @needsAuth
    options.headers = $.extend(headers, options.headers)
    super(method, model, options)

  parse: (data) ->
    @meta = data.meta
    data.response

  setData: (data) ->
    @set(@parse(data))
