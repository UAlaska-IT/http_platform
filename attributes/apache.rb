# frozen_string_literal: true

tcb = 'http_platform'

default[tcb]['apache']['install_test_suite'] = false

default[tcb]['apache']['mpm_module'] = 'default_mpm'

default[tcb]['apache']['extra_mods_to_install'] = {}

default[tcb]['admin_email'] = nil

default[tcb]['cipher_generator'] = 'HIGH:!aNULL:!kRSA:!SHA:@STRENGTH'
default[tcb]['ciphers_to_remove'] = ['-CBC-']
default[tcb]['ssl_protocol'] = 'All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1'

default['apache']['mod_ssl']['ssl_protocol'] = node[tcb]['ssl_protocol']

default[tcb]['apache']['use_stapling'] = true

default[tcb]['apache']['paths_to_additional_configs'] = { 'conf-available/ssl-host.conf' => '' }
