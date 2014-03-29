module.exports = class LoggedIn extends Chaplin.Model

   initialize: (response) ->
     super
     @set 'response', response
