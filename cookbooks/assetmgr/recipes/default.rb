#
# Cookbook Name:: assetmgr
# Recipe:: default
#
# Copyright 2013, SzechNet
#
# All rights reserved - Do Not Redistribute
#

applicaiton "assetmgr" do
  path "/deploy/assetmgr"
  owner 'assetmgr'
  group 'assetmgr'

  repository 'http://github.szechnet.com/szechyjs/assetmgr.git'
  revision 'master'

  rails do
    bundler true
  end

  unicorn do
    worker_processes 2
  end
end
