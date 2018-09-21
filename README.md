# Secure Apache Cookbook

[![License](https://img.shields.io/github/license/calsev/secure_apache.svg)](https://github.com/calsev/secure_apache)
[![GitHub Tag](https://img.shields.io/github/tag/calsev/secure_apache.svg)](https://github.com/calsev/secure_apache)

__Maintainer: Caleb J. Severn__ (<calnoreply@gmail.com>)

## Purpose

Configures HTTPS hosts in Apache with certificate and reasonably tight cypher and protocol suites.

To test configuration
```bash
sudo apachectl configtest
```

## Requirements

### Chef

This cookbook requires Chef 14+

### Platforms

Supported Platform Families:

* Debian
  * Ubuntu, Mint
* Red Hat Enterprise Linux
  * Amazon, CentOS, Oracle

Platforms validated via Test Kitchen:

* Ubuntu
* CentOS

### Dependencies

This cookbook does not constrain its dependencies because it is intended as a utility library.  It should ultimately be used within a wrapper cookbook.

## Resources

This cookbook provides no custom resources.

## Examples

This is an application cookbook; no custom resources are provided.  See recipes and attributes for details of what this cookbook does.

## Development

See CONTRIBUTING.md and TESTING.md.
