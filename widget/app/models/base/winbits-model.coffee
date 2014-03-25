module.exports = class WinbitsModel extends Model
  _: Winbits._

  initialize: (options) ->
    super
    @_ = options._ or @_