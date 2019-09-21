#
# Author:: Matt Kasa <mattk@granicus.com>
# Cookbook Name:: http_deploy
# Provider:: http_deploy
#
# Copyright:: 2014, Granicus Inc. <mattk@granicus.com>
#
# This file is part of http_deploy.
#
# http_deploy is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# http_deploy is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with http_deploy.  If not, see <http://www.gnu.org/licenses/>.
#

require 'tmpdir'

use_inline_resources if defined?(use_inline_resources)

action :deploy do
  # Make an alias we can use in Chef resource names
  alias_name = new_resource.name.gsub(/[[:space:][:punct:]]/, '_')

  # Ensure required attributes are not nil, otherwise error and return
  required_attributes = [:url, :path]
  missing_attributes = required_attributes.keep_if { |attr| new_resource.send(attr).nil? }

  if missing_attributes.empty?
    # Define path to download a build to and the path to deploy it to
    build_path = ::File.join(::Dir.tmpdir, new_resource.resource_name.to_s)
    if !new_resource.builds.nil?
      build_path = ::File.join(new_resource.builds, new_resource.name)
    elsif Chef::Config[:file_cache_path]
      build_path = ::File.join(Chef::Config[:file_cache_path], new_resource.resource_name.to_s)
    end
    deploy_path = ::File.join(new_resource.path, new_resource.name)

    # Make sure the parent directories exist
    [::File.dirname(build_path), new_resource.path].each do |path|
      directory path do
        not_if { ::File.directory?(path) }
        owner 'root'
        group 'root'
        mode '0755'
        recursive true
        action :create
      end
    end

    # Deploy the file from the builds directory into the deploy path if needed
    resource = ruby_block "deploy_#{alias_name}" do
      action :nothing
      block do
        # Copy build to deploy path
        ::FileUtils.cp(build_path, deploy_path)

        # Make sure deployed file is owned by the same user/group as the parent directory
        # TODO: offer owner/group attributes to allow customization
        parent = ::File.stat(new_resource.path)
        ::File.chown(parent.uid, parent.gid, deploy_path)
      end
      not_if {
        if ::File.exists?(deploy_path)
          ::Chef::Log.info("#{new_resource.resource_name}[#{new_resource.name}] comparing #{build_path} to #{deploy_path}")
          ::FileUtils.compare_file(build_path, deploy_path)
        else
          ::Chef::Log.info("#{new_resource.resource_name}[#{new_resource.name}] deploying to #{deploy_path}")
          false
        end
      } if ::File.exists?(build_path)
    end

    # Download the url into the builds directory if needed
    remote_file "download_#{alias_name}" do
      path build_path
      mode '0755'
      source new_resource.url
      action (::File.exists?(build_path) ? :nothing : :create)
      notifies :create, "ruby_block[deploy_#{alias_name}]", :immediately
    end

    # HEAD the url to see if it needs to be downloaded
    http_request "check_#{alias_name}" do
      message ''
      url new_resource.url
      action :head
      headers 'If-Modified-Since' => ::File.mtime(build_path).httpdate if ::File.exists?(build_path)
      notifies :create, "remote_file[download_#{alias_name}]", :immediately
    end

    ruby_block "execute_#{alias_name}" do
      local_resource = resource
      block do
        local_resource.run_action(:create)
        new_resource.updated_by_last_action(true) if local_resource.updated_by_last_action?
      end
    end
  else
    missing_attributes.each do |attr|
      ::Chef::Log.error("#{new_resource.resource_name}[#{new_resource.name}] missing required attribute '#{attr}'")
    end
    return
  end
end
