module.exports = (match) ->
  match '', 'home#index'
  match 'login', 'login#index'
  match 'logged-in', 'logged-in#index'
  match 'not-logged-in', 'not-logged-in#index'
  match 'register', 'register#index'
  match 'wb-recover-password', 'recover-password#index'
#  match 'wb-reset-password', 'recover-password#index'
  match 'my-profile', 'my-profile#index'
  match 'wb-complete-register-:apiToken', 'hash#completeRegister'
  match 'wb-register-complete', 'complete-register#index'


  match 'wb-switch-user-:apiToken', 'hash#switchUser'
  match 'wb-reset-password-:salt', 'hash#resetPassword'