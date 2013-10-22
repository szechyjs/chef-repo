name 'basic'
description 'Basic configuration'
run_list(
  'recipe[apt]',
  'recipe[yum::yum]',
  'recipe[git]'
)
