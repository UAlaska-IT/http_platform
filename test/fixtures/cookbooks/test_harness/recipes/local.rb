# frozen_string_literal: true

bash 'Local Hostname' do
  code 'hostnamectl set-hostname funny.business'
end

include_recipe 'http_platform::default'
