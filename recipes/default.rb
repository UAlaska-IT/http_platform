# frozen_string_literal: true

tcb = 'http_platform'

raise 'http_platform::default configures a server. see ReadMe for use' unless configure_server?

include_recipe "#{tcb}::definitions"

include_recipe "#{tcb}::local_cert" if node[tcb]['configure_cert']

include_recipe "#{tcb}::firewall" if node[tcb]['configure_firewall']

include_recipe "#{tcb}::_server"

include_recipe "#{tcb}::certbot_cert" if node[tcb]['configure_lets_encrypt_cert']
