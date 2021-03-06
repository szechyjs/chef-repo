name             'testapp'
maintainer       'SzechNet'
maintainer_email 'jared.szechy@gmail.com'
license          'All rights reserved'
description      'Installs/Configures test rails app'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'users'
depends 'runit'
depends 'database'
depends 'ruby_build'
depends 'application'
depends 'application_ruby'
depends 'chef-solo-search'
