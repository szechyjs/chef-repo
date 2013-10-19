name 'assetmgr'
description 'AssetMgr Rails Application'
run_list(
  'role[basic]',
  'role[nginx]',
  'role[postgresql]',
  'recipe[assetmgr]'
)
