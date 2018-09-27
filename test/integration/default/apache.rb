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

describe file(conf_dir + '/ssl_params.conf') do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe bash('apachectl configtest') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match 'Syntax OK' } # Yep, output is on stderr
  its(:stdout) { should eq '' }
end

describe bash('apache2ctl -M') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match 'headers_module' }
  its(:stdout) { should match 'rewrite_module' }
  its(:stdout) { should match 'ssl_module' }
end
