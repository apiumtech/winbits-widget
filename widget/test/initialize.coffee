
specs = [
  './views/not-logged-in-view-spec',
  './views/logged-in-view-spec',
  './views/header-view-spec',
  './views/register-view-spec',
  './views/login-view-spec',
  './views/my-profile-view-spec'
]

for spec in specs
    console.log ['Executing Spec -> ', spec]
    require spec
