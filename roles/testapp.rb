name 'testapp'
description 'Test Rails Application'
run_list(
  'role[basic]',
  'role[postgresql]',
  'recipe[testapp]'
)
