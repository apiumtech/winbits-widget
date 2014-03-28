
specs = [
  './views/header-view-spec',
  './views/login-view-spec'
]

for spec in specs
    console.log ['Executing Spec -> ', spec]
    require spec
