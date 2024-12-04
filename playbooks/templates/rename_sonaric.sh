#!/bin/bash

set -e

echo "Running sonaric node-rename"
sonaric node-rename <<EOF
$1
EOF

echo "Running sonaric identity-export"
sonaric identity-export <<EOF
$2
$2
EOF