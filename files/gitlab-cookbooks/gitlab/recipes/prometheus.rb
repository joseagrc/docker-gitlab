#
# Copyright:: Copyright (c) 2017 GitLab Inc.
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

account_helper = AccountHelper.new(node)
prometheus_user = account_helper.prometheus_user
prometheus_log_dir = node['gitlab']['prometheus']['log_directory']
prometheus_dir = node['gitlab']['prometheus']['home']

include_recipe 'gitlab::prometheus_user'

directory prometheus_dir do
  owner prometheus_user
  mode '0755'
  recursive true
end

directory prometheus_log_dir do
  owner prometheus_user
  mode '0700'
  recursive true
end

template "#{prometheus_dir}/prometheus.yml" do
  source 'prometheus.yml.erb'
  owner prometheus_user
  mode '0644'
  notifies :restart, 'service[prometheus]'
end

runit_service 'prometheus' do
  options({
    log_directory: prometheus_log_dir
  }.merge(params))
  log_options node['gitlab']['logging'].to_hash.merge(
    node['gitlab']['registry'].to_hash
  )
end
