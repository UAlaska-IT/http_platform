# frozen_string_literal: true

tcb = 'http_platform'

raise 'http_platform::default configures a server. see ReadMe for use' unless configure_server?

# Hostname is predictably changed on the first run and not reloaded, so go ahead and do it here
id_tag = 'Reload Hostname'

ohai id_tag do
  not_if { idempotence_file?(id_tag) }
end

idempotence_file id_tag

include_recipe "#{tcb}::definitions"

include_recipe "#{tcb}::local_cert" if node[tcb]['configure_cert']

include_recipe "#{tcb}::firewall" if node[tcb]['configure_firewall']

include_recipe "#{tcb}::_server"

include_recipe "#{tcb}::certbot_cert" if node[tcb]['configure_lets_encrypt_cert']
