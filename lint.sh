#!/usr/bin/env bash

rubocop
foodcritic .
foodcritic test/cookbooks/test_harness
cookstyle .
cookstyle test/cookbooks/test_harness
