# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe file(path_to_ca_signed_cert(node)) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'BEGIN CERTIFICATE' }
  its(:content) { should match 'MIIFBjCCA+6gAwIBAgIVAM' } # The first characters of the data
end

# Special fields for this cert
describe file(path_to_ssl_host_conf(node)) do
  its(:content) { should match "SSLCertificateFile #{path_to_ca_signed_cert(node)}" }
  its(:content) { should match "SSLCertificateKeyFile #{path_to_private_key(node)}" }
end
