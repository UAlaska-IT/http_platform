# frozen_string_literal: true

tcb = 'secure_apache'

# The mods to install, in addition to headers, rewrite, ssl
# Include the mod name only, e.g. php, without prefix 'mod_'
default[tcb]['apache']['extra_mods_to_install'] = {}

default[tcb]['www']['document_root'] = '/var/www/html'
# Do not enable this without a CA cert
default[tcb]['www']['use_stapling'] = 'Off'

default[tcb]['www']['remove_default_index'] = true

# An array of rules; these will be matched first to last
# comment - optional, will be placed above the rule
# url_regex - required, the regex for the URL
# path_regex - required, the regex for the generated path
# flags - optional, the flags for the rule, e.g. '[L,NC]', https://httpd.apache.org/docs/2.4/rewrite/flags.html
default[tcb]['www']['rewrite_rules'] = []

default['apache']['contact'] = node['nix_baseline']['admin_email']

# Used for certs also
default['apache']['mod_ssl']['cipher_suite'] = 'HIGH:!aNULL:!kRSA:!SHA:@STRENGTH'
