# frozen_string_literal: true

name 'http_platform'
maintainer 'OIT Systems Engineering'
maintainer_email 'ua-oit-se@alaska.edu'
license 'MIT'
description 'Installs/Configures an HTTPS server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
issues_url 'https://github.alaska.edu/oit-cookbooks/http_platform/issues' if respond_to?(:issues_url)
source_url 'https://github.alaska.edu/oit-cookbooks/http_platform' if respond_to?(:source_url)

version '0.2.0'

supports 'ubuntu', '>= 16.0'
supports 'centos', '>= 7.0'

chef_version '>= 14.0' if respond_to?(:chef_version)

depends 'apache2'
depends 'firewall'
