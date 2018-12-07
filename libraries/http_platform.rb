# frozen_string_literal: true

module HttpPlatform
  # This module implements shared utility code for consistency with dependent cookbooks
  module Helper
    TCB = 'http_platform'

    def cert_public_directory
      return '/etc/ssl/certs' if node['platform_family'] == 'debian'

      return '/etc/pki/tls/certs'
    end

    def cert_private_directory
      return '/etc/ssl/private' if node['platform_family'] == 'debian'

      return '/etc/pki/tls/private'
    end

    def apache_service
      return 'apache2' if node['platform_family'] == 'debian'

      return 'httpd'
    end

    def path_to_elinks_config
      return '/etc/elinks/elinks.conf' if node['platform_family'] == 'debian'

      return '/etc/elinks.conf'
    end

    def cert_prefix
      return 'http_platform'
    end

    def path_to_csr
      return File.join(cert_public_directory, cert_prefix + '_csr.pem')
    end

    def path_to_vault_cert
      return File.join(cert_public_directory, cert_prefix + '_vault_cert.pem')
    end

    def path_to_vault_key
      return File.join(cert_private_directory, cert_prefix + '_vault_key.pem')
    end

    def vault_cert_exists?
      return File.exist?(path_to_vault_cert)
    end

    def path_to_lets_encrypt_cert
      # This is the one-file/cert+chain version, for modern Apache
      return "/etc/letsencrypt/live/#{plain_server_name(node['fqdn'])}/fullchain.pem"
    end

    def path_to_lets_encrypt_key
      return "/etc/letsencrypt/live/#{plain_server_name(node['fqdn'])}/privkey.pem"
    end

    def lets_encrypt_cert_exists?
      return File.exist?(path_to_lets_encrypt_cert) && File.exist?(path_to_lets_encrypt_key)
    end

    def use_vault_cert?
      # Must be 'lazy' to use vault cert on first run
      return node[TCB]['configure_vault_cert'] # && vault_cert_exists?
    end

    def use_lets_encrypt_cert?
      # Cannot be 'lazy'; must fetch cert at end and use next run
      return !use_vault_cert? && node[TCB]['configure_lets_encrypt_cert'] && lets_encrypt_cert_exists?
    end

    def use_self_signed_cert?
      return !use_vault_cert? && !use_lets_encrypt_cert?
    end

    def path_to_self_signed_cert
      return File.join(cert_public_directory, cert_prefix + '_ss_cert.pem')
    end

    def path_to_self_signed_key
      return File.join(cert_private_directory, cert_prefix + '_key.pem')
    end

    def path_to_private_key
      return path_to_vault_key if use_vault_cert? && node[TCB]['key']['vault_item_key']

      return path_to_lets_encrypt_key if use_lets_encrypt_cert?

      return path_to_self_signed_key
    end

    def path_to_ssl_cert
      return path_to_vault_cert if use_vault_cert?

      return path_to_lets_encrypt_cert if use_lets_encrypt_cert?

      return path_to_self_signed_cert
    end

    def path_to_dh_config
      return File.join(cert_private_directory, 'dh_config.txt')
    end

    def path_to_dh_params
      return File.join(cert_public_directory, 'dh_param.pem')
    end

    def cert_common_name
      name_attrib = node[TCB]['cert']['common_name']
      return name_attrib unless name_attrib.nil?

      return node['fqdn']
    end

    def conf_root_directory
      return '/etc/apache2' if node['platform_family'] == 'debian'

      return '/etc/httpd'
    end

    def config_relative_directory
      return 'conf.d' # Must match default conf from attributes
    end

    def config_absolute_directory
      return File.join(conf_root_directory, config_relative_directory)
    end

    def conf_available_directory
      return File.join(conf_root_directory, 'conf-available')
    end

    def conf_enabled_directory
      return File.join(conf_root_directory, 'conf-enabled')
    end

    def ssl_conf_name
      return 'ssl-params.conf'
    end

    def ssl_host_conf_name
      return 'ssl-host.conf' # Must match default conf from attributes
    end

    def cert_email
      return node[TCB]['admin_email'] if node[TCB]['cert']['email'].nil?

      return node[TCB]['cert']['email']
    end

    def bash_out(command)
      stdout, stderr, status = Open3.capture3(command)
      raise "Error: #{stderr}" unless stderr.empty?

      raise "Status: #{status}" if status != 0

      return stdout
    end

    def remove_cipher?(cipher)
      return true if cipher.empty?

      node[TCB]['ciphers_to_remove'].each do |regex|
        return true if cipher.match?(Regexp.new(regex))
      end
      return false
    end

    def remove_ciphers(ciphers)
      cipher_list = []
      ciphers.split(':').each do |cipher|
        cipher = cipher.strip
        next if remove_cipher?(cipher)

        cipher_list.append(cipher)
      end
      return cipher_list
    end

    def http_cipher_suite
      generator = node[TCB]['cipher_generator']
      ciphers = bash_out("openssl ciphers #{generator}")
      cipher_list = remove_ciphers(ciphers)
      raise "Cipher string too tight, only #{cipher_list.length} ciphers" unless cipher_list.length > 7

      return cipher_list.join(':')
    end

    def host_is_www(host)
      return host =~ /^www\./
    end

    def www_server_name(host)
      return host if host_is_www(host)

      return 'www.' + host
    end

    def plain_server_name(host)
      return host unless host_is_www(host)

      remainder = host[4..-1]
      fqdn_regex = /localhost|[a-z0-9]+(\.[a-z0-9]+)+/
      raise "FQDN must include root domain: #{host}, #{remainder}" unless remainder =~ fqdn_regex

      return remainder
    end

    def other_server_name(host)
      return plain_server_name(host) if host_is_www(host)

      return www_server_name(host)
    end

    def insert_duplicate_options(aliases, host, options)
      aliases[host] =
        if node[TCB]['www']['additional_aliases'].key?(host)
          JSON.parse(JSON.generate(node[TCB]['www']['additional_aliases'][host]))
        else
          JSON.parse(JSON.generate(options))
        end
    end

    def insert_options(aliases, host, options)
      insert_duplicate_options(aliases, host, options)
      aliases[host]['log_prefix'] = plain_server_name(host) unless aliases[host].key?('log_prefix')
    end

    def insert_ordered_aliases(aliases, host, options)
      # www_host always comes first, so we may co-opt list order
      insert_options(aliases, www_server_name(host), options)
      insert_options(aliases, plain_server_name(host), options)
    end

    def insert_alias_pair(aliases, host)
      return if aliases.key?(host) # We already processed the sibling

      options = node[TCB]['www']['additional_aliases'][host]
      options = {} if options.nil? # This happens for FQDN hosts
      insert_ordered_aliases(aliases, host, options)
    end

    def generate_alias_pairs
      aliases = {}
      insert_alias_pair(aliases, node['fqdn'])
      # insert_alias_pair(aliases, 'localhost') if node[TCB]['apache']['install_test_suite']
      node[TCB]['www']['additional_aliases'].each do |host, _|
        insert_alias_pair(aliases, host)
      end
      return aliases
    end

    def generate_domain_names
      aliases = generate_alias_pairs # www names are first
      names = []
      aliases.each do |name, _|
        names.append(other_server_name(name)) # List plain names first
      end
      return names
    end

    def generate_alt_names
      aliases = generate_alias_pairs
      names = []
      aliases.each do |name, _|
        names.append("DNS:#{name}")
      end
      return names
    end

    def vault_secret(bag, item, key)
      # Will raise 404 error if not found
      item = chef_vault_item(
        bag,
        item
      )
      raise 'Unable to retrieve vault item' if item.nil?

      secret = item[key]
      raise 'Unable to retrieve item key' if secret.nil?

      return secret
    end
  end
end

Chef::Provider.include(HttpPlatform::Helper)
Chef::Recipe.include(HttpPlatform::Helper)
Chef::Resource.include(HttpPlatform::Helper)
