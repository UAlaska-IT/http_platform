# frozen_string_literal: true

tcb = 'http_platform'

default[tcb]['www']['document_root'] = '/var/www/html'

default[tcb]['www']['remove_default_index'] = true
default[tcb]['www']['create_default_index'] = false

default[tcb]['www']['access_directories'] = { '/' => '' }

default[tcb]['www']['error_documents'] = {}

default[tcb]['www']['additional_aliases'] = {}

default[tcb]['www']['redirect_rules'] = []

default[tcb]['www']['rewrite_rules'] = []

default[tcb]['www']['header_policy']['referrer'] = true
default[tcb]['www']['header_policy']['x_frame'] = true
default[tcb]['www']['header_policy']['x_content'] = true
default[tcb]['www']['header_policy']['xss'] = true
