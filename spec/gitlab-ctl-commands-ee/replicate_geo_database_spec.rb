require 'omnibus-ctl'
require 'chef_helper'

describe 'gitlab-ctl replicate-geo-database' do
  subject { Omnibus::Ctl.new('testing-ctl') }

  before do
    allow_any_instance_of(Omnibus::Ctl).to receive(:require).and_call_original
    allow_any_instance_of(Omnibus::Ctl).to receive(:require).with(
      '/opt/testing-ctl/embedded/service/omnibus-ctl-ee/lib/geo/replication'
    ) do
      require_relative('../../files/gitlab-ctl-commands-ee/lib/geo/replication')
    end

    subject.load_file('files/gitlab-ctl-commands-ee/replicate_geo_database.rb')
  end

  it 'appends a geo replication command' do
    expect(subject.get_all_commands_hash).to include('replicate-geo-database')
  end

  it 'executes the geo replication command when called' do
    arguments = %w(--host=gitlab-primary.geo --slot-name=gitlab_primary_geo --sslmode=disable)

    allow_any_instance_of(Omnibus::Ctl::GeoReplicationCommand)
      .to receive(:arguments).and_return(arguments)

    expect(Geo::Replication).to receive(:new).and_call_original
      .with(subject, hash_including(host: 'gitlab-primary.geo',
                                    slot_name: 'gitlab_primary_geo',
                                    sslmode: 'disable'))

    expect_any_instance_of(Geo::Replication).to receive(:execute)

    subject.replicate_geo_database
  end
end
