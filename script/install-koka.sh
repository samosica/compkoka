#!/usr/bin/env bash

KOKA_VERSION=$1

if [ "$KOKA_VERSION" = latest ]; then
    KOKA_INSTALLER_URL="https://github.com/koka-lang/koka/releases/latest/download/install.sh"
else
    KOKA_INSTALLER_URL="https://github.com/koka-lang/koka/releases/download/${KOKA_VERSION}/install.sh"
fi

curl -sSL "$KOKA_INSTALLER_URL" -o /tmp/install.sh
chmod +x /tmp/install.sh
/tmp/install.sh --minimal
rm /tmp/install.sh
