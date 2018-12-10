# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe file(path_to_lets_encrypt_cert) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'BEGIN CERTIFICATE' }
end

describe file(path_to_lets_encrypt_key) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'BEGIN RSA PRIVATE KEY' }
end

['/etc/letsencrypt', '/etc/letsencrypt/live'].each do |dir|
  describe file(dir) do
    it { should exist }
    it { should be_directory }
    it { should be_mode 0o750 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'adm' }
  end
end

# Special fields for this cert
describe file(path_to_ssl_host_conf(node)) do
  its(:content) { should match "SSLCertificateFile #{path_to_lets_encrypt_cert}" }
  its(:content) { should match "SSLCertificateKeyFile #{path_to_lets_encrypt_key}" }
end
