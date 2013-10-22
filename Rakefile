#
# Rakefile for Chef Server Repository
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rubygems'
require 'chef'
require 'json'
require 'highline/import'
require 'etc'

# Load constants from rake config file.
require File.join(File.dirname(__FILE__), 'config', 'rake')

# Detect the version control system and assign to $vcs. Used by the update
# task in chef_repo.rake (below). The install task calls update, so this
# is run whenever the repo is installed.
#
# Comment out these lines to skip the update.

if File.directory?(File.join(TOPDIR, ".svn"))
  $vcs = :svn
elsif File.directory?(File.join(TOPDIR, ".git"))
  $vcs = :git
end

# Load common, useful tasks from Chef.
# rake -T to see the tasks this loads.

load 'chef/tasks/chef_repo.rake'

desc "Bundle a single cookbook for distribution"
task :bundle_cookbook => [ :metadata ]
task :bundle_cookbook, :cookbook do |t, args|
  tarball_name = "#{args.cookbook}.tar.gz"
  temp_dir = File.join(Dir.tmpdir, "chef-upload-cookbooks")
  temp_cookbook_dir = File.join(temp_dir, args.cookbook)
  tarball_dir = File.join(TOPDIR, "pkgs")
  FileUtils.mkdir_p(tarball_dir)
  FileUtils.mkdir(temp_dir)
  FileUtils.mkdir(temp_cookbook_dir)

  child_folders = [ "cookbooks/#{args.cookbook}", "site-cookbooks/#{args.cookbook}" ]
  child_folders.each do |folder|
    file_path = File.join(TOPDIR, folder, ".")
    FileUtils.cp_r(file_path, temp_cookbook_dir) if File.directory?(file_path)
  end

  system("tar", "-C", temp_dir, "-cvzf", File.join(tarball_dir, tarball_name), "#{args.cookbook}")

  FileUtils.rm_rf temp_dir
end

desc "Deploy a new node"
task :deploy do
  type = ""
  role = "basic"

  choose do |menu|
    menu.prompt = "Please choose a destination to deploy to: "
    menu.choice :ec2 do type = "ec2" end
    menu.choice :vsphere do type = "vsphere" end
    menu.choice :xen do type = "xen" end
  end

  choose do |menu|
    menu.prompt = "Please choose a role for the node: "
    menu.choice :basic do role = "basic" end
    menu.choice :nginx do role = "nginx" end
    menu.choice :postgresql do role = "postgresql" end
    menu.choice :testapp do role = "testapp" end
  end

  node_name = ask("Enter the name of the node: ") {|q| q.default = "new-node" }

  case type
    when "ec2"
      instance_type = "t1.micro"
      image = "ubuntu1204"
      ami = "ami-b9a2f0d0"
      user = "ubuntu"
      zone = "us-east-1d"
      region = "us-east-1"

      zone_ami = {
        "us-east-1d" => {
          "ubuntu1204" => "ami-a73264ce",
          "ubuntu1304" => "ami-ad83d7c4",
          "centos6" => "ami-eb6b0182"
        },
        "us-west-1b" => {
          "ubuntu1204" => "ami-acf9cde9",
          "ubuntu1304" => "ami-7e37033b",
          "centos6" => "ami-b9341afc"
        },
        "us-west-2a" => {
          "ubuntu1204" => "ami-6aad335a",
          "ubuntu1304" => "ami-12fe6022",
          "centos6" => "ami-b158c981"
        }
      }

      choose do |menu|
        menu.prompt = "Please select an availability zone: "
        menu.choice :us_east_1 do zone = "us-east-1d"; region = "us-east-1" end
        menu.choice :us_west_1 do zone = "us-west-1b"; region = "us-west-1" end
        menu.choice :us_west_2 do zone = "us-west-2a"; region = "us-west-2" end
      end

      choose do |menu|
        menu.prompt = "Please select an image: "
        menu.choice :ubuntu1204 do image = "ubuntu1204" end
        menu.choice :ubuntu1304 do image = "ubuntu1304" end
        menu.choice :centos6 do image = "centos6"; user = "root" end
      end

      ami = zone_ami[zone][image]

      choose do |menu|
        menu.prompt = "Please select an instance type: "
        menu.choice :micro do instance_type = "t1.micro" end
        menu.choice :small do instance_type = "m1.small" end
        menu.choice :medium do instance_type = "m1.medium" end
        menu.choice :large do instance_type = "m1.large" end
        menu.choice :xlarge do instance_type = "m1.xlarge" end
      end

      spot_price = ask("Enter spot request price in USD (0 for regular instance): ", Float) do |q|
        q.default = 0
      end

      spot_tag = spot_price != 0 ? "--spot-price #{spot_price}" : ""

      cmd = "knife ec2 server create --node-name #{node_name} --run-list \"role[#{role}]\" --flavor #{instance_type} --availability-zone #{zone} --region #{region} --image #{ami} --ssh-user #{user} --identity-file ~/.chef/ec2.pem --tags Role=#{role},Owner=#{Etc.getlogin},ManagedBy=chef #{spot_tag}"

    when "vsphere"
    when "xen"
  end

  puts cmd
  system cmd
end
