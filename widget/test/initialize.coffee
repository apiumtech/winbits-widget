
specs = [
  './models/header-spec',
  './views/not-logged-in-view-spec',
  './views/logged-in-view-spec',
  './views/header-view-spec',
  './views/register-view-spec',
  './views/login-view-spec',
  './views/my-account-view-spec',
  './views/recover-password-view-spec',
  './views/reset-password-view-spec',
  './views/personal-data-view-spec',
  './views/social-media-view-spec',
  './views/change-password-view-spec',
  './views/shipping-addresses-view-spec',
  './other/jquery-location-select-spec',
  './views/complete-register-view-spec'
]

for spec in specs
    console.log ['Executing Spec -> ', spec]
    require spec
