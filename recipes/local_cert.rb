# frozen_string_literal: true

tcb = 'http_platform'

valid_email = node[tcb]['admin_email'] || node[tcb]['cert']['email']
raise 'Set node[\'http_platform\'][\'admin_email\'] or node[\'http_platform\'][\'cert\'][\'email\']' unless valid_email

include_recipe "#{tcb}::_generate_cert"

include_recipe "#{tcb}::_vault_cert" if node[tcb]['configure_vault_cert']
