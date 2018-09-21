# frozen_string_literal: true

tcb = 'secure_apache'

default[tcb]['www']['document_root'] = '/var/www/html'
# Do not enable this without a CA cert
default[tcb]['www']['use_stapling'] = 'Off'

default[tcb]['www']['remove_default_index'] = true

default['apache']['contact'] = node['nix_baseline']['admin_email']

default['apache']['mod_ssl']['cipher_suite'] = node['nix_baseline']['cert']['cipher_string']
