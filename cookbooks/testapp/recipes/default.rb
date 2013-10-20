#
# Cookbook Name:: assetmgr
# Recipe:: default
#
# Copyright 2013, SzechNet
#
# All rights reserved - Do Not Redistribute
#
if Chef::Config[:solo]
  include_recipe 'chef-solo-search'
end

include_recipe "users"

users_manage "deploy" do
  group_id 2500
  action [ :remove, :create ]
end

package "libpq-dev" do
  action :install
end

include_recipe 'ruby_build'

ruby_build_ruby '1.9.3-p429' do
  prefix_path '/usr/local/'
  environment 'CFLAGS' => '-g -O2'
  action :install
end

gem_package 'bundler' do
  version '1.3.5'
  gem_binary '/usr/local/bin/gem'
  options '--no-ri --no-rdoc'
end

include_recipe 'postgresql::ruby'

postgresql_database 'testapp' do

  connection(
    :host     => '127.0.0.1',
    :port     => 5432,
    :username => 'postgres',
    :password => node ? node['postgresql']['password']['postgres'] : 'password'
  )
  owner 'postgres'
  action :create
end

include_recipe 'runit'

application "testapp" do
  path "/deploy/testapp"
  owner 'testapp'
  group 'deploy'

  repository 'https://github.com/szechyjs/todo.git'
  revision 'master'

  migrate true

  rails do
    bundler true
    use_omnibus_ruby false
    precompile_assets true
    database do
      adapter "postgresql"
      host "localhost"
      database "testapp"
      username "postgres"
      password node ? node['postgresql']['password']['postgres'] : "password"
    end
  end

  unicorn do
    worker_processes 2
  end
end
