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
