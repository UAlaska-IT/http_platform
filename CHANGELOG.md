# Changelog for HTTP Platform Cookbook

## 2.3.2

* Make Apache templates lazy
* Ensure redirects and rewrites are mashes

## 2.3.1

* Update pipeline
* Test new Ubuntu
* Add support for Fedora

## 2.3.0

* Always force update of APT on first run
* Eliminate redundant php directive

## 2.2.2

* Actually support redirect regex

## 2.2.1

* Sync kitchen attributes

## 2.2.0

* Improve one-run idempotence
* Add attribute for mpm module

## 2.1.0

* Fixed missing group ssl-cert on debian

## 2.0.2

* Fixed eager evaluations of fqdn

## 2.0.1

* Fixed trying to copy certs when running Certbot delayed

## 2.0.0

* Updated to apache2 7 cookbook
* Added Appveyor pipeline

## 1.4.4

* Cleanup for Supermarket

## 1.4.3

* Updated kitchen to use EC2
* Added pin for apache2 cookbook

## 1.4.2

* Tightened permissions on some configs

## 1.4.1

* Implemented header policies

## 1.4.0

* Implemented automatic stapling

## 1.3.2

* Fixed key group on CentOS

## 1.3.1

* Fixed permission issues for Certbot cert

## 1.3.0

* Added support for webroot and standalone strategies for fetching cert.

## 1.2.0

* Added support for fetching a cert on Nginx
* Reorganized workflow to support serverless install of certs

## 1.1.0

* Added group permissions on all certs

## 1.0.0

* Certbot now works
* Implemented access directories and files

## 0.3.1

* Fixed bug in function for lets encrypt

## 0.3.0

* Added management of cert from vault
* Added management of cert from certbot

## 0.2.2

* Eliminated empty ciphers

## 0.2.1

* Improved handling of cert and apache gates

## 0.2.0

* Now deleting legacy confs
* Added support for alt names
* Made cert mutable

## 0.1.3

* Added filtering of cipher suites

## 0.1.2

* Added test suite

## 0.1.1

* Added explicit dependency on firewall cookbook

## 0.1.0

* Initial release
