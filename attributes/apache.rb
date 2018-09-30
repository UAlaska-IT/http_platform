# frozen_string_literal: true

tcb = 'http_platform'

# The mods to install, in addition to headers, rewrite, ssl
# Include the mod name only, e.g. php, without prefix 'mod_'
default[tcb]['apache']['extra_mods_to_install'] = {}

default[tcb]['admin_email'] = nil # This must be set or an exception is raised
default['apache']['contact'] = node[tcb]['admin_email']

# Used for certs also
default[tcb]['cipher_suite'] = 'HIGH:!aNULL:!kRSA:!SHA:@STRENGTH'
# Explicit TLSv1.3 breaks negotiation on Ubuntu 16.04, Chef Server 12.17.33
default[tcb]['ssl_protocol'] = 'All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1'

default['apache']['mod_ssl']['cipher_suite'] = node[tcb]['cipher_suite']
default['apache']['mod_ssl']['ssl_protocol'] = node[tcb]['ssl_protocol']
