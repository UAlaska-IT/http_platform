# frozen_string_literal: true

module SecureApache
  # This module implements shared utility code for consistency with dependent cookbooks
  module Helper
    TCB = 'secure_apache'

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
      return effective_host_name
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
      return effective_host_name
    end
  end
end

Chef::Provider.include(SecureApache::Helper)
Chef::Recipe.include(SecureApache::Helper)
Chef::Resource.include(SecureApache::Helper)
