#!/usr/bin/env bash

if [ -e /compkoka/.koka-version ]; then
    KOKA_VERSION=$(cat /compkoka/.koka-version)
fi

if [ "$KOKA_VERSION" = latest ]; then
    KOKA_INSTALLER_URL="https://github.com/koka-lang/koka/releases/latest/download/install.sh"
else
    KOKA_INSTALLER_URL="https://github.com/koka-lang/koka/releases/download/${KOKA_VERSION}/install.sh"
fi

curl -sSL "$KOKA_INSTALLER_URL" -o /tmp/install.sh
chmod +x /tmp/install.sh
/tmp/install.sh --minimal
rm /tmp/install.sh
