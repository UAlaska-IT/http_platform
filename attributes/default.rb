# frozen_string_literal: true

tcb = 'http_platform'

default[tcb]['configure_firewall'] = true
default[tcb]['configure_cert'] = true # Create a self-signed cert and possibly other certs
default[tcb]['configure_apache'] = true

# These flags control certificate usage
# Precedence is vault > lets encrypt > self-signed
default[tcb]['configure_vault_cert'] = false # Fetch cert from vault also
default[tcb]['configure_lets_encrypt_cert'] = false # Use certbot to fetch cert also
