# frozen_string_literal: true

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

def path_to_self_signed_cert(node)
  return File.join(cert_public_dir(node), 'funny.business_cert_self_signed.pem')
end

def path_to_private_key(node)
  return File.join(cert_private_dir(node), 'funny.business_key.pem')
end

def path_to_dh_params(node)
  return File.join(cert_public_dir(node), 'dh_param.pem')
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
