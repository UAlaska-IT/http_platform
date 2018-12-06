# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

# Special fields for this cert
describe file(path_to_ssl_host_conf(node)) do
  its(:content) { should match "SSLCertificateFile #{path_to_self_signed_cert(node)}" }
  its(:content) { should match "SSLCertificateKeyFile #{path_to_private_key(node)}" }
end
