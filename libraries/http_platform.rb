# frozen_string_literal: true

module HttpPlatform
  # This module implements shared utility code for consistency with dependent cookbooks
  module Helper
    TCB = 'http_platform'

    def apache_service
      return 'apache2' if node['platform_family'] == 'debian'
      return 'httpd'
    end

    def path_to_ca_signed_cert
      pub_dir = node[TCB]['cert']['cert_public_directory']
      return pub_dir + node[TCB]['cert']['ca_signed']['cert_public_file_name']
    end

    def path_to_ca_signed_key
      key_dir = node[TCB]['cert']['cert_private_directory']
      return key_dir + node[TCB]['cert']['ca_signed']['cert_private_file_name']
    end

    def ca_signed_cert?
      have_ca_cert = ::File.exist?(path_to_ca_signed_cert)
      have_ca_key = ::File.exist?(path_to_ca_signed_key)
      return have_ca_cert && have_ca_key
    end

    def self_signed_cert_prefix
      prefix_attrib = node[TCB]['cert']['self_signed']['cert_prefix']
      return prefix_attrib unless prefix_attrib.nil?
      return node['fqdn']
    end

    def path_to_self_signed_cert
      pub_dir = node[TCB]['cert']['cert_public_directory']
      cert_post = node[TCB]['cert']['self_signed']['cert_public_suffix']
      return pub_dir + self_signed_cert_prefix + cert_post
    end

    def path_to_self_signed_key
      key_dir = node[TCB]['cert']['cert_private_directory']
      key_post = node[TCB]['cert']['self_signed']['cert_private_suffix']
      return key_dir + self_signed_cert_prefix + key_post
    end

    def path_to_ssl_cert
      return path_to_ca_signed_cert if ca_signed_cert?
      return path_to_self_signed_cert
    end

    def path_to_ssl_key
      return path_to_ca_signed_key if ca_signed_cert?
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

    def config_relative_directory
      return 'conf.d' # Must match default conf from attributes
    end

    def config_absolute_directory
      return '/etc/apache2/' + config_relative_directory if node['platform_family'] == 'debian'
      return '/etc/httpd/' + config_relative_directory
    end

    def ssl_host_conf_name
      return 'ssl-host.conf' # Must match default conf from attributes
    end

    def host_is_www(host)
      return host =~ /^www\./
    end

    def www_server_name
      return node['fqdn'] if host_is_www(node['fqdn'])
      return 'www.' + node['fqdn']
    end

    def plain_server_name
      return node['fqdn'] unless host_is_www(node['fqdn'])
      remainder = node['fqdn'][4..-1]
      raise 'FQDN must include root domain' unless remainder =~ /(!\.)+\.(!\.)+/
      return remainder
    end

    def insert_alias_pair(aliases, host)
      if host_is_www(host)
        aliases[host] = host[4..-1]
      else
        aliases['www.' + host] = host
      end
    end

    def generate_alias_pairs
      aliases = {}
      node[TCB]['www']['additional_aliases'].each do |host, _|
        insert_alias_pair(aliases, host)
      end
      return aliases
    end
  end
end

Chef::Provider.include(HttpPlatform::Helper)
Chef::Recipe.include(HttpPlatform::Helper)
Chef::Resource.include(HttpPlatform::Helper)
