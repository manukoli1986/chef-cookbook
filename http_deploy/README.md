http_deploy Cookbook
====================
This cookbook downloads and deploys a binary package using HTTP.

Resource/Provider
-----------------
### http_deploy
#### Actions
- :deploy: Download and deploy a binary package using HTTP

#### Attribute Parameters
- :url: URL of the file to be deployed
- :path: The directory to deploy the file into
- :builds: The directory to store the download in (defaults to `Chef::Client[:file_cache_path]` if it's defined otherwise it falls back to the OS tmpdir)

#### Examples
Deploy a WAR file into a tomcat instance

```ruby
http_deploy 'app.war' do
  url 'http://some-bucket.s3.amazonaws.com/builds/app_production.war'
  path node[:tomcat][:webapp_dir]
end
```

Usage
-----
#### <cookbook>/metadata.rb:
```ruby
depends 'http_deploy'
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License & Authors
-----------------
- Author:: Matt Kasa (<mattk@granicus.com>)

```text
Copyright 2014, Granicus Inc.

This file is part of http_deploy.

http_deploy is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

http_deploy is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with http_deploy.  If not, see <http://www.gnu.org/licenses/>.
```
