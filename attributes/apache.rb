# frozen_string_literal: true

tcb = 'http_platform'

# Testing facilities
default[tcb]['apache']['install_test_suite'] = false

# The mods to install, in addition to headers, rewrite, ssl
# Include the mod name only, e.g. php, without prefix 'mod_'
# See https://github.com/sous-chefs/apache2#recipes for a list of modules
default[tcb]['apache']['extra_mods_to_install'] = {}

default[tcb]['admin_email'] = nil # This must be set or an exception is raised; also default for cert
default['apache']['contact'] = node[tcb]['admin_email']

# Used for certs also
default[tcb]['cipher_generator'] = 'HIGH:!aNULL:!kRSA:!SHA:@STRENGTH'
default[tcb]['ciphers_to_remove'] = ['_CBC_']
# Explicit TLSv1.3 breaks negotiation on Ubuntu 16.04, Chef Server 12.17.33
default[tcb]['ssl_protocol'] = 'All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1'

default['apache']['mod_ssl']['ssl_protocol'] = node[tcb]['ssl_protocol']

# Do not enable this without a CA cert
default[tcb]['apache']['use_stapling'] = 'off'

# Paths to configs to be included by all HTTPS hosts
# Most applications will want to merge this and keep the default conf
default[tcb]['apache']['paths_to_additional_configs'] = { 'conf.d/ssl-host.conf' => '' }
