require 'resolv'

module GitlabCtl
  class PostgreSQL
    class EE
      class << self
        def get_primary
          node_attributes = GitlabCtl::Util.get_node_attributes
          consul_enable = node_attributes.dig('consul', 'enable')
          postgresql_service_name = node_attributes.dig('patroni', 'scope')

          raise 'Consul agent is not enabled on this node' unless consul_enable

          raise 'PostgreSQL service name is not defined' if postgresql_service_name.nil? || postgresql_service_name.empty?

          result = []
          Resolv::DNS.open(nameserver_port: [['127.0.0.1', 8600]]) do |dns|
            result = dns.getresources("master.#{postgresql_service_name}.service.consul", Resolv::DNS::Resource::IN::SRV).map do |srv|
              "#{dns.getaddress(srv.target)}:#{srv.port}"
            end
          end

          raise 'PostgreSQL Primary could not be found via Consul DNS' if result.empty?

          result
        end
      end
    end
  end
end
