# frozen_string_literal: true

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

if node['platform_family'] == 'debian'
  public_dir = '/etc/ssl/certs/'
  private_dir = '/etc/ssl/private/'
elsif node['platform_family'] == 'rhel'
  public_dir = '/etc/pki/tls/certs'
  private_dir = '/etc/pki/tls/private/'
else
  raise "Platform family not recognized: #{node['platform_family']}"
end

describe file(public_dir + 'funny_cert_self_signed.pem') do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o600 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file(private_dir + 'funny_key_self_signed.pem') do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o600 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file(public_dir + 'dh_param.pem') do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end
