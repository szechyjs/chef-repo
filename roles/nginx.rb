name 'nginx'
description 'nginx web server'
run_list(
  'role[basic]',
  'recipe[nginx]'
)
