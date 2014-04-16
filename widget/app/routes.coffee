module.exports = (match) ->
  match '', 'home#index'
  match 'wb-login', 'login#index'
  match 'wb-logged-in', 'logged-in#index'
  match 'wb-not-logged-in', 'not-logged-in#index'
  match 'wb-register', 'register#index'
  match 'wb-recover-password', 'recover-password#index'
  match 'wb-reset-password', 'reset-password#index'
  match 'wb-profile', 'my-profile#index'
  match 'wb-complete-register', 'complete-register#index'


  match 'wb-complete-register-:apiToken', 'hash#completeRegister'
  match 'wb-switch-user-:apiToken', 'hash#switchUser'
  match 'wb-reset-password-:salt', 'hash#resetPassword'