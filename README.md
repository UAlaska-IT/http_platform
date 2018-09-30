# Secure Apache Cookbook

[![License](https://img.shields.io/github/license/calsev/http_platform.svg)](https://github.com/calsev/http_platform)
[![GitHub Tag](https://img.shields.io/github/tag/calsev/http_platform.svg)](https://github.com/calsev/http_platform)

__Maintainer: Caleb J. Severn__ (<calnoreply@gmail.com>)

## Purpose

Configures an HTTPS server with a certificate and secure cypher and protocol suites.

This cookbook is intended as a base for rapidly prototyping websites and as such favors opinion over flexibility.

* HTTP redirects to HTTPS
* Multiple host names are supported, but hosts are little more than name aliases
* Host share these attributes
  * Certificate
  * Redirects
  * Rewrite rules
  * Error documents
  * Configs
  * Content (root and access directories)
* Host are distinguished by
  * Log files
  * Log level

Currently only Apache is supported.

ToDo:

* Manage CSR, switching hosts to CA-signed cert once in place

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
