module.exports = (match) ->
  match '', 'home#index'
  match 'login', 'login#index'
  match 'logged-in', 'logged-in#index'
  match 'not-logged-in', 'not-logged-in#index'
