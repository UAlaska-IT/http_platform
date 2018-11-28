# frozen_string_literal: true

module HttpPlatform
  # This module implements shared utility code for consistency with dependent cookbooks
  module Helper
    TCB = 'http_platform'

    def apache_service
      return 'apache2' if node['platform_family'] == 'debian'

      return 'httpd'
    end

    def path_to_elinks_config
      return '/etc/elinks/elinks.conf' if node['platform_family'] == 'debian'

      return '/etc/elinks.conf'
    end

    def cert_prefix
      prefix_attrib = node[TCB]['cert']['prefix']
      return prefix_attrib unless prefix_attrib.nil?

      return node['fqdn']
    end

    def path_to_ca_signed_cert
      pub_dir = node[TCB]['cert']['cert_public_directory']
      return pub_dir + node[TCB]['cert']['ca_signed']['cert_public_file_name']
    end

    def ca_signed_cert?
      return ::File.exist?(path_to_ca_signed_cert)
    end

    def path_to_self_signed_cert
      pub_dir = node[TCB]['cert']['cert_public_directory']
      cert_post = node[TCB]['cert']['self_signed']['cert_public_suffix']
      return pub_dir + cert_prefix + cert_post
    end

    def path_to_self_signed_key
      key_dir = node[TCB]['cert']['cert_private_directory']
      key_post = node[TCB]['cert']['self_signed']['cert_private_suffix']
      return key_dir + cert_prefix + key_post
    end

    def path_to_ssl_cert
      return path_to_ca_signed_cert if ca_signed_cert?

      return path_to_self_signed_cert
    end

    def path_to_ssl_key
      return path_to_self_signed_key
    end

    def path_to_dh_config
      key_dir = node[TCB]['cert']['cert_private_directory']
      return key_dir + 'dh_config.txt'
    end

    def self_signed_cert?
      has_ss_cert = ::File.exist?(path_to_self_signed_cert)
      has_ss_key = ::File.exist?(path_to_self_signed_key)
      return has_ss_cert && has_ss_key
    end

    def path_to_dh_params
      pub_dir = node[TCB]['cert']['cert_public_directory']
      return pub_dir + node[TCB]['cert']['dh_param']['dh_param_file_name']
    end

    def cert_common_name
      name_attrib = node[TCB]['cert']['self_signed']['common_name']
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
      raise "FQDN must include root domain: #{host}, #{remainder}" unless remainder =~ /[a-z0-9]+(\.[a-z0-9]+)+/

      return remainder
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
      node[TCB]['www']['additional_aliases'].each do |host, _|
        insert_alias_pair(aliases, host)
      end
      return aliases
    end

    def generate_alt_names
      aliases = generate_alias_pairs
      names = []
      aliases.each do |name, _|
        names.append("DNS:#{name}")
      end
      return names
    end
  end
end

Chef::Provider.include(HttpPlatform::Helper)
Chef::Recipe.include(HttpPlatform::Helper)
Chef::Resource.include(HttpPlatform::Helper)
