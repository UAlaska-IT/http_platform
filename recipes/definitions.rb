# frozen_string_literal: true

id_tag = 'Pre-Install Update'

apt_update id_tag do
  action :update
  not_if { idempotence_file?(id_tag) }
end

idempotence_file id_tag

include_recipe 'apt::default'

package apache_package

# On debian certs are grouped into ssl-cert but the group does not exist
package 'ssl-cert' if platform_family?('debian')

# This block creates an explicit declaration for the service created by installing the apache2 package
# Therefore client cookbooks can notify this service
service 'apache2' do
  extend Apache2::Cookbook::Helpers
  service_name(lazy { apache_platform_service_name })
  supports restart: true, status: true, reload: true
  action :nothing
end
