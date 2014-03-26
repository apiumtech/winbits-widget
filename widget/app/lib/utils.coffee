# Application-specific utilities
# ------------------------------

# Delegate to Chaplin’s utils module.
utils = Chaplin.utils.beget Chaplin.utils

# _(utils).extend
#  someMethod: ->
Winbits._(utils).extend
  redirectToLoggedInHome: ->
    @redirectTo controller: 'logged-in', action: 'index'

  redirectToNotLoggedInHome: ->
    @redirectTo 'not-logged-in#index'

# Prevent creating new properties and stuff.
Object.seal? utils

module.exports = utils
