# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe file(path_to_lets_encrypt_key(node)) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into key_group(node) }
  its(:content) { should match '-----BEGIN RSA PRIVATE KEY-----\nMIIE' }
end

describe key_rsa(path_to_lets_encrypt_key(node)) do
  it { should be_public }
  it { should be_private }
  its('public_key') { should match '-----BEGIN PUBLIC KEY-----\nMIIB' }
  its('private_key') { should match '-----BEGIN RSA PRIVATE KEY-----\nMIIE' }
  its('key_length') { should eq 2048 }
end

describe file(path_to_lets_encrypt_cert(node)) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'BEGIN CERTIFICATE' }
end

describe x509_certificate(path_to_self_signed_cert(node)) do
  its('version') { should eq 2 }
  its('key_length') { should eq 2048 }
  its('signature_algorithm') { should eq 'sha256WithRSAEncryption' }
  its('validity_in_days') { should be > 89 }
  its('validity_in_days') { should be < 91 }

  its('extensions') { should include 'subjectAltName' }

  its('issuer.CN') { should eq 'Let\'s Encrypt Authority X3' }
  its('issuer.C') { should eq 'US' }
  its('issuer.O') { should eq 'Let\'s Encrypt' }
end

describe apache_conf(File.join(path_to_conf_available_dir(node), 'ssl-params.conf')) do
  its('SSLUseStapling') { should eq ['on'] }
end

# Special fields for this cert
describe file(path_to_ssl_host_conf(node)) do
  its(:content) { should match "SSLCertificateFile #{path_to_lets_encrypt_cert}" }
  its(:content) { should match "SSLCertificateKeyFile #{path_to_lets_encrypt_key}" }
end
