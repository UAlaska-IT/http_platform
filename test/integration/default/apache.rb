# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

if node['platform_family'] == 'debian'
  apache_service = 'apache2'
elsif node['platform_family'] == 'rhel'
  apache_service = 'httpd'
else
  raise "Platform family not recognized: #{node['platform_family']}"
end

describe package(apache_service) do
  it { should be_installed }
  its(:version) { should match(/^2\.4/) }
end

describe service(apache_service) do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe apache_conf do
  its('Listen') { should match ['*:80', '*:443'] }
end
