# frozen_string_literal: true

def apache_package(node)
  return 'apache2' if node['platform_family'] == 'debian'

  return 'httpd'
end

def cert_public_dir(node)
  if node['platform_family'] == 'debian'
    dir = '/etc/ssl/certs'
  elsif node['platform_family'] == 'rhel'
    dir = '/etc/pki/tls/certs'
  else
    raise "Platform family not recognized: #{node['platform_family']}"
  end
  return dir
end

def cert_private_dir(node)
  if node['platform_family'] == 'debian'
    dir = '/etc/ssl/private'
  elsif node['platform_family'] == 'rhel'
    dir = '/etc/pki/tls/private'
  else
    raise "Platform family not recognized: #{node['platform_family']}"
  end
  return dir
end

def path_to_conf_root_dir(node)
  return '/etc/apache2' if node['platform_family'] == 'debian'

  return '/etc/httpd'
end

def path_to_conf_available_dir(node)
  return File.join(path_to_conf_root_dir(node), 'conf-available')
end

def path_to_ssl_host_conf(node)
  File.join(path_to_conf_available_dir(node), 'ssl-host.conf')
end

def path_to_self_signed_cert(node)
  return File.join(cert_public_dir(node), 'http_platform_ss_cert.pem')
end

def path_to_ca_signed_cert(node)
  return File.join(cert_public_dir(node), 'http_platform_vault_cert.pem')
end

def path_to_lets_encrypt_cert(node)
  return File.join(cert_public_dir(node), 'http_platform_le_cert.pem')
end

def path_to_self_signed_key(node)
  return File.join(cert_private_dir(node), 'http_platform_key.pem')
end

def path_to_vault_key(node)
  return File.join(cert_private_dir(node), 'http_platform_vault_key.pem')
end

def path_to_lets_encrypt_key(node)
  return File.join(cert_private_dir(node), 'http_platform_le_key.pem')
end

def path_to_dh_config(node)
  return File.join(cert_private_dir(node), 'dh_config.txt')
end

def path_to_dh_params(node)
  return File.join(cert_public_dir(node), 'dh_param.pem')
end

def conf_available_dir(node)
  return File.join(path_to_conf_root_dir(node), 'conf-available')
end

def conf_enabled_dir(node)
  return File.join(path_to_conf_root_dir(node), 'conf-enabled')
end

def sites_available_dir(node)
  return File.join(path_to_conf_root_dir(node), 'sites-available')
end

def sites_enabled_dir(node)
  return File.join(path_to_conf_root_dir(node), 'sites-enabled')
end

def apache_service(node)
  if node['platform_family'] == 'debian'
    service = 'apache2'
  elsif node['platform_family'] == 'rhel'
    service = 'httpd'
  else
    raise "Platform family not recognized: #{node['platform_family']}"
  end
  return service
end

def key_group(node)
  return 'ssl-cert' if node['platform_family'] == 'debian'

  return 'root'
end
