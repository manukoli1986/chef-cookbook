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

actions :deploy
default_action :deploy

attribute :name, :kind_of => String, :name_attribute => true
attribute :url, :kind_of => String, :default => nil
attribute :path, :kind_of => String, :default => nil
attribute :builds, :kind_of => String, :default => nil
