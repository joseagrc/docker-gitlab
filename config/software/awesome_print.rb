#
# Copyright 2018 GitLab Inc.
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

name 'awesome_print'
default_version '1.8.0'

license 'MIT'
license_file "https://github.com/awesome-print/awesome_print/blob/v#{version}/LICENSE"

dependency 'ruby'
dependency 'rubygems'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem 'install awesome_print' \
      " --version '#{version}'" \
      ' --no-ri --no-rdoc', env: env
end
