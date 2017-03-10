#!/bin/bash

set -e

for framework in $1/*.framework; do
    rm -rf "$2/$(basename $framework)"
    cp -Rf "$framework" "$2"
done
