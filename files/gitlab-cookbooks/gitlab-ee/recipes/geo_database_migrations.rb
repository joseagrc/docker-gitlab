#
# Copyright:: Copyright (c) 2016 GitLab Inc.
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

omnibus_helper = OmnibusHelper.new(node)

dependent_services = []
dependent_services << "unicorn_service[unicorn]" if omnibus_helper.should_notify?("unicorn")
dependent_services << "runit_service[puma]" if omnibus_helper.should_notify?("puma")
dependent_services << "runit_service[actioncable]" if omnibus_helper.should_notify?("actioncable")
dependent_services << "sidekiq_service[sidekiq]" if omnibus_helper.should_notify?("sidekiq")

rails_migration "gitlab-geo tracking" do
  migration_task 'geo:db:migrate'
  migration_logfile_prefix 'gitlab-geo-db-migrate'
  migration_helper GitlabGeoHelper.new(node)

  dependent_services dependent_services
  notifies :run, 'execute[start geo-postgresql]', :before if omnibus_helper.should_notify?('geo-postgresql')
end
