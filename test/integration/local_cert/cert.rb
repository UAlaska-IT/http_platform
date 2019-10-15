# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe x509_certificate(path_to_self_signed_cert(node)) do
  its('subject.CN') { should eq 'funny.business' }

  its('extensions.subjectAltName') { should include 'DNS:funny.business' }
  its('extensions.subjectAltName') { should include 'DNS:www.funny.business' }
  its('extensions.subjectAltName') { should include 'DNS:me.also' }
  its('extensions.subjectAltName') { should include 'DNS:www.me.also' }

  its('issuer.CN') { should eq 'funny.business' }
end

alt_regex = 'subject_alt_name: \["DNS:www.funny.business", "DNS:funny.business", "DNS:www.me.also", "DNS:me.also"\]'

describe file('/opt/chef/run_record/http_cert_record.txt') do
  its(:content) { should match 'common_name: funny.business' }
  its(:content) { should match alt_regex }
end
