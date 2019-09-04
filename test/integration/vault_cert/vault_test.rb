# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe file(path_to_vault_key(node)) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o640 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into key_group(node) }
  its(:content) { should match '-----BEGIN RSA PRIVATE KEY-----\nMIIE' }
  its(:content) { should match 'MIIEpQIBAAKCAQEAmdeLBWsW3xYyCCcijBjQb' }
end

describe key_rsa(path_to_vault_key(node)) do
  it { should be_public }
  it { should be_private }
  its('public_key') { should match '-----BEGIN PUBLIC KEY-----\nMIIB' }
  its('private_key') { should match '-----BEGIN RSA PRIVATE KEY-----\nMIIE' }
  its('key_length') { should eq 2048 }
end

describe file(path_to_ca_signed_cert(node)) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'BEGIN CERTIFICATE' }
  its(:content) { should match '6gAwIBAgIVAM2EyVtFbBhD5K29iY60ULQ/gIbnMA0GCSqGSIb3DQEB' } # No escape, near beginning
end

describe x509_certificate(path_to_self_signed_cert(node)) do
  its('version') { should eq 2 }
  its('key_length') { should eq 2048 }
  its('signature_algorithm') { should eq 'sha256WithRSAEncryption' }
  its('validity_in_days') { should be > 364 }
  its('validity_in_days') { should be < 366 }

  its('subject.CN') { should eq 'funny.business' }
  its('subject.emailAddress') { should eq 'fake-it@make-it' }
  its('subject.C') { should eq 'US' }
  its('subject.ST') { should eq 'Alaska' }
  its('subject.L') { should eq 'Fairbanks' }
  its('subject.O') { should eq 'fake_org' }
  its('subject.OU') { should eq 'fake_unit' }

  its('extensions') { should include 'subjectAltName' }
  its('extensions.subjectAltName') { should include 'DNS:funny.business' }
  its('extensions.subjectAltName') { should include 'DNS:www.funny.business' }
  # its('extensions.subjectAltName') { should include 'DNS:localhost' }
  # its('extensions.subjectAltName') { should include 'DNS:www.localhost' }
  its('extensions.subjectAltName') { should include 'DNS:me.also' }
  its('extensions.subjectAltName') { should include 'DNS:www.me.also' }

  its('issuer.CN') { should eq 'funny.business' }
  its('issuer.emailAddress') { should eq 'fake-it@make-it' }
  its('issuer.C') { should eq 'US' }
  its('issuer.ST') { should eq 'Alaska' }
  its('issuer.L') { should eq 'Fairbanks' }
  its('issuer.O') { should eq 'fake_org' }
  its('issuer.OU') { should eq 'fake_unit' }
end

describe apache_conf(File.join(path_to_conf_available_dir(node), 'ssl-params.conf')) do
  its('SSLUseStapling') { should eq ['on'] }
end

# Special fields for this cert
describe file(path_to_ssl_host_conf(node)) do
  its(:content) { should match "SSLCertificateFile #{path_to_ca_signed_cert(node)}" }
  its(:content) { should match "SSLCertificateKeyFile #{path_to_vault_key(node)}" }
end
