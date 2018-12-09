# frozen_string_literal: true

tcb = 'http_platform'

include_recipe "#{tcb}::local_cert" if node[tcb]['configure_cert']

include_recipe "#{tcb}::server" if configure_server?

include_recipe "#{tcb}::certbot_cert" if node[tcb]['configure_lets_encrypt_cert']
