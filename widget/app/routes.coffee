module.exports = (match) ->
  match '', 'home#index'
  match 'home#login', controller: 'login', action: 'showLogin'
  match 'home#logged', controller: 'logged', action: 'showLogged'
