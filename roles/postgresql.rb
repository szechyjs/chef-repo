name 'postgresql'
description 'postgresql server'
run_list(
  'role[basic]',
  'recipe[postgresql::server]'
)
