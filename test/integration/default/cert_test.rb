# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe file(path_to_self_signed_cert(node)) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o600 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file(path_to_self_signed_key(node)) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o600 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file(path_to_dh_params(node)) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe x509_certificate(path_to_self_signed_cert(node)) do
  its('version') { should eq 2 }
  its('key_length') { should eq 2048 }
  its('signature_algorithm') { should eq 'sha256WithRSAEncryption' }
  its('validity_in_days') { should be > 364 }
  its('validity_in_days') { should be < 366 }

  its('subject.CN') { should eq 'funny.business' }
  its('subject.emailAddress') { should eq 'webmaster.calsev@gmail.com' }
  its('subject.C') { should eq 'US' }
  its('subject.ST') { should eq 'Alaska' }
  its('subject.L') { should eq 'Fairbanks' }
  its('subject.O') { should eq 'fake_org' }
  its('subject.OU') { should eq 'fake_unit' }

  its('issuer.CN') { should eq 'funny.business' }
  its('issuer.emailAddress') { should eq 'webmaster.calsev@gmail.com' }
  its('issuer.C') { should eq 'US' }
  its('issuer.ST') { should eq 'Alaska' }
  its('issuer.L') { should eq 'Fairbanks' }
  its('issuer.O') { should eq 'fake_org' }
  its('issuer.OU') { should eq 'fake_unit' }
end
