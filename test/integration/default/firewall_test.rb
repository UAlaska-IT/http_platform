# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

firewall_conf = if node['platform_family'] == 'debian'
                  '/etc/default/ufw-chef.rules'
                else
                  '/etc/sysconfig/firewalld-chef.rules'
                end

describe file(firewall_conf) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

if node['platform_family'] == 'debian'
  describe file(firewall_conf) do
    its(:content) { should match 'ufw allow in proto tcp to any port 80 from any' }
    its(:content) { should match 'ufw allow in proto tcp to any port 443 from any' }
  end
else
  describe file(firewall_conf) do
    its(:content) { should match '--dports 80' }
    its(:content) { should match '--dports 443' }
  end
end

describe port(80) do
  it { should be_listening }
  its('processes') { should eq [apache_service(node)] }
  its('protocols') { should eq ['tcp'] }
end

describe port(443) do
  it { should be_listening }
  its('processes') { should eq [apache_service(node)] }
  its('protocols') { should eq ['tcp'] }
end
