# On debian certs are grouped into ssl-cert but the group does not exist
package Apache2::Cookbook::Helpers::apache_pkg

# This block creates an explicit declaration for the service created by installing the apache2 package
# Therefore client cookbooks can notify this service
service apache_service do
  extend Apache2::Cookbook::Helpers
  service_name(lazy { apache_platform_service_name })
  supports restart: true, status: true, reload: true
  action :nothing
end
