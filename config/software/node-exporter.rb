#
## Copyright:: Copyright (c) 2014 GitLab.com
## License:: Apache License, Version 2.0
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
#

name "node-exporter"
default_version "v0.13.0"

license "APACHE-2.0"
license_file "LICENSE"

source git: "https://github.com/prometheus/node_exporter.git"

relative_path "src/github.com/prometheus/node_exporter"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env = {
    'GOPATH' => "#{Omnibus::Config.source_dir}/node-exporter",
    'GO15VENDOREXPERIMENT' => '1' # Build machines have go 1.5.x, use vendor directory
  }
  exporter_source_dir = "#{Omnibus::Config.source_dir}/node-exporter"
  cwd = "#{exporter_source_dir}/src/github.com/prometheus/node_exporter"

  command "go build", env: env, cwd: cwd
  copy "node_exporter", "#{install_dir}/embedded/bin/"
end
