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
  its(:content) { should match '6gAwIBAgIVAM2EyVtFbBhD5K29iY60ULQ/gIbnMA0GCSqGSIb3DQEB' } # No escape, near beginning
end

describe file(path_to_vault_key(node)) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'adm' }
  its(:content) { should match 'BEGIN RSA PRIVATE KEY' }
  its(:content) { should match 'MIIEpQIBAAKCAQEAmdeLBWsW3xYyCCcijBjQb' } # No escape, near beginning
end

# Special fields for this cert
describe file(path_to_ssl_host_conf(node)) do
  its(:content) { should match "SSLCertificateFile #{path_to_ca_signed_cert(node)}" }
  its(:content) { should match "SSLCertificateKeyFile #{path_to_vault_key(node)}" }
end
