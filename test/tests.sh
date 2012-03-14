#!/usr/bin/env bash

# (requires jasmine-node)

jasmine-node --coffee --verbose `dirname $0`/specs
