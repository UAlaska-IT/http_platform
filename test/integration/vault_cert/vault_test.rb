# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe file(File.join(cert_public_dir(node), 'funny.business_cert_ca_request.pem')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o600 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match 'BEGIN CERTIFICATE REQUEST' }
end
