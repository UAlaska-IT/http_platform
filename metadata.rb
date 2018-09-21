# frozen_string_literal: true

name 'secure_apache'
maintainer 'Caleb Severn'
maintainer_email 'calnoreply@gmail.com'
license 'MIT'
description 'Installs/Configures an HTTPS server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url 'https://github.com/calsev/secure_apache/issues' if respond_to?(:issues_url)
source_url 'https://github.com/calsev/secure_apache' if respond_to?(:source_url)

version '0.1.0'

supports 'ubuntu', '>= 16.0'
supports 'centos', '>= 7.0'

chef_version '>= 14.0' if respond_to?(:chef_version)

depends 'apache2'
depends 'nix_baseline'
