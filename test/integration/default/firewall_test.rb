# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

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
