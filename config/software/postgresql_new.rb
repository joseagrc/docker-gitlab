#
# Copyright 2012-2014 Chef Software, Inc.
# Copyright:: Copyright (c) 2016 GitLab Inc.
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

name 'postgresql_new'
default_version '10.0'

license 'PostgreSQL'
license_file 'COPYRIGHT'

skip_transitive_dependency_licensing true

dependency 'zlib'
dependency 'openssl'
dependency 'libedit'
dependency 'ncurses'
dependency 'libossp-uuid'
dependency 'config_guess'

version '10.0' do
  source sha256: '712f5592e27b81c5b454df96b258c14d94b6b03836831e015c65d6deeae57fd1'
end

# PostgreSQL 10 should have a major version of 10, not 10.0.
# See: https://www.postgresql.org/support/versioning
#
# Be sure to update files/gitlab-cookbooks/postgresql/recipes/enable.rb when
# upgrading.
major_version = '10'

source url: "https://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"

relative_path "postgresql-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  prefix = "#{install_dir}/embedded/postgresql/#{major_version}"
  update_config_guess(target: 'config')

  patch source: 'no_docs.patch', target: 'GNUmakefile.in'

  command './configure' \
          " --prefix=#{prefix}" \
          ' --with-libedit-preferred' \
          ' --with-openssl' \
          ' --with-ossp-uuid', env: env

  make "world -j #{workers}", env: env
  make 'install-world', env: env
end

# exclude headers and static libraries from package
project.exclude "embedded/bin/pg_config"
project.exclude "embedded/postgresql/#{major_version}/include"
project.exclude "embedded/postgresql/#{major_version}/lib/*.a"
project.exclude "embedded/postgresql/#{major_version}/lib/pgxs"
project.exclude "embedded/postgresql/#{major_version}/lib/pkgconfig"
