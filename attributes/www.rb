# frozen_string_literal: true

tcb = 'http_platform'

default[tcb]['www']['document_root'] = '/var/www/html'

default[tcb]['www']['remove_default_index'] = true
default[tcb]['www']['create_default_index'] = false

# Only requests to these directories will be accepted
default[tcb]['www']['access_directories'] = { '/' => '' }

# A mapping of status => path to document, e.g. { 404 => '/404_kitten.php' }
default[tcb]['www']['error_documents'] = {}

# We always create plain and www aliases for the FQDN
# This is a map of additional aliases to options, e.g. { 'other.url' => {} }
# Currently the only option recognized is log_level, see https://httpd.apache.org/docs/2.4/mod/core.html#loglevel
# If both the plain and www host are included, these are treated as independent
# Otherwise they will be created as a matched pair with identical options
# The www host will always be placed before the plain host
default[tcb]['www']['additional_aliases'] = {}

# An array of rules; these will be matched first to last
# comment - optional, will be placed above the rule
# url_regex - required, the regex for the URL
# path_regex - required, the regex for the generated path
# flags - optional, the flags for the rule, e.g. '[L,NC]', https://httpd.apache.org/docs/2.4/rewrite/flags.html
default[tcb]['www']['rewrite_rules'] = []
