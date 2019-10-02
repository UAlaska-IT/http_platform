# frozen_string_literal: true

include_recipe 'apt::default'

package apache_package

# On debian certs are grouped into ssl-cert but the group does not exist
if platform_family?('debian')
  package 'ssl-cert'
end

# This block creates an explicit declaration for the service created by installing the apache2 package
# Therefore client cookbooks can notify this service
service 'apache2' do
  extend Apache2::Cookbook::Helpers
  service_name(lazy { apache_platform_service_name })
  supports restart: true, status: true, reload: true
  action :nothing
end
