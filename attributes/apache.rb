# frozen_string_literal: true

tcb = 'http_platform'

# The mods to install, in addition to headers, rewrite, ssl
# Include the mod name only, e.g. php, without prefix 'mod_'
default[tcb]['apache']['extra_mods_to_install'] = {}

default[tcb]['www']['document_root'] = '/var/www/html'
# Do not enable this without a CA cert
default[tcb]['www']['use_stapling'] = 'off'

default[tcb]['www']['remove_default_index'] = true
default[tcb]['www']['create_default_index'] = false

# Only requests to these directories will be accepted
default[tcb]['www']['access_directories'] = { '/' => '' }

# An array of rules; these will be matched first to last
# comment - optional, will be placed above the rule
# url_regex - required, the regex for the URL
# path_regex - required, the regex for the generated path
# flags - optional, the flags for the rule, e.g. '[L,NC]', https://httpd.apache.org/docs/2.4/rewrite/flags.html
default[tcb]['www']['rewrite_rules'] = []

default[tcb]['admin_email'] = nil # This must be set or an exception is raised
default['apache']['contact'] = node[tcb]['admin_email']

# Used for certs also
default[tcb]['cipher_suite'] = 'HIGH:!aNULL:!kRSA:!SHA:@STRENGTH'
# Explicit TLSv1.3 breaks negotiation on Ubuntu 16.04, Chef Server 12.17.33
default[tcb]['ssl_protocol'] = 'All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1'

default['apache']['mod_ssl']['cipher_suite'] = node[tcb]['cipher_suite']
default['apache']['mod_ssl']['ssl_protocol'] = node[tcb]['ssl_protocol']
