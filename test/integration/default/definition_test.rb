# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe package(apache_package(node)) do
  it { should be_installed }
end

describe package('ssl-cert') do
  it { should be_installed }
  before do
    skip unless node['platform_family'] == 'debian'
  end
end
