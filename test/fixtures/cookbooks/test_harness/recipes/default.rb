# frozen_string_literal: true

bash 'Hostname' do
  code 'hostnamectl set-hostname funny.business'
end

include_recipe 'http_platform::default'
