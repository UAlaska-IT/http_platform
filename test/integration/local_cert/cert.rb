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
